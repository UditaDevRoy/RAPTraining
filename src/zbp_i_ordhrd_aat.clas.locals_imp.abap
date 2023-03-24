CLASS lcl_buffer DEFINITION.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_buffer_ord.
             INCLUDE TYPE zordhd_aat AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer_ord.

    TYPES: tt_buffer_ord TYPE STANDARD TABLE OF ty_buffer_ord.

    CLASS-DATA mt_buffer_ord TYPE tt_buffer_ord.

ENDCLASS.

CLASS lhc_SOrd DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE SOrd.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE SOrd.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE SOrd.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK SOrd.

    METHODS read FOR READ
      IMPORTING keys FOR READ SOrd RESULT result.

      METHODS set_status FOR MODIFY
      IMPORTING keys FOR ACTION SOrd~set_status RESULT result.

      METHODS get_features  FOR FEATURES IMPORTING keys REQUEST requested_features FOR SOrd RESULT result.

ENDCLASS.

CLASS lhc_SOrd IMPLEMENTATION.

  METHOD create.
  DATA ls_failed LIKE LINE OF reported-sord.

  LOOP AT entities INTO DATA(ls_create).

  IF ls_create-VendorId IS INITIAL.
    APPEND VALUE #(
            %cid    = ls_create-%cid
            %create = if_abap_behv=>mk-on
        ) TO failed-sord.
           ls_failed-%cid = ls_create-%cid.
          ls_failed-%element-sord = if_abap_behv=>mk-on.
          ls_failed-%msg = new_message( id       = 'ZRAP'
                                                           number   = 000
                                                           severity = if_abap_behv_message=>severity-error
                                                            ).
          APPEND ls_failed  TO reported-sord.
          ELSEIF ls_create-CustomerId IS INITIAL.
    APPEND VALUE #(
            %cid    = ls_create-%cid
            %create = if_abap_behv=>mk-on
        ) TO failed-sord.

           ls_failed-%cid = ls_create-%cid.
          ls_failed-%element-sord = if_abap_behv=>mk-on.
          ls_failed-%msg = new_message( id       = 'ZRAP'
                                                           number   = 001
                                                           severity = if_abap_behv_message=>severity-error
                                                            ).
          APPEND ls_failed  TO reported-sord.
          ELSE.
              GET TIME STAMP FIELD DATA(lv_tsl).
      SELECT MAX( sord ) FROM zordhd_aat INTO @DATA(lv_max_sord).   "get last servord num
      lv_max_sord = lv_max_sord + 1.
      SHIFT lv_max_sord LEFT DELETING LEADING space.
      ls_create-%data-CreatedAt = lv_tsl.
      ls_create-%data-CreatedBy = sy-uname.
      APPEND INITIAL LINE TO lcl_buffer=>mt_buffer_ord ASSIGNING FIELD-SYMBOL(<buffer>).
      <buffer>-sord = lv_max_sord.
      <buffer>-customer_id = ls_create-%data-CustomerId.
      <buffer>-vendor_id = ls_create-%data-VendorId.
      <buffer>-delivery_country = ls_create-%data-DeliveryCountry.
      <buffer>-overall_status = ls_create-%data-OverallStatus.
      <buffer>-order_conf_date = ls_create-%data-OrderConfDate.
      <buffer>-delivery_date = ls_create-%data-DeliveryDate.
      <buffer>-created_at = lv_tsl.
      <buffer>-created_by = sy-uname.
      <buffer>-description = ls_create-%data-Description.
      <buffer>-remarks = ls_create-%data-Remarks.
      <buffer>-flag = 'C'.
      INSERT VALUE #( %cid = ls_create-%cid sord = lv_max_sord ) INTO TABLE mapped-sord.
  ENDIF.


    ENDLOOP.

  ENDMETHOD.

  METHOD delete.
  LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_delete>).
      IF <lfs_delete>-sord IS NOT INITIAL.
        INSERT VALUE #( sord = <lfs_delete>-sord ) INTO TABLE mapped-sord.
        APPEND INITIAL LINE TO lcl_buffer=>mt_buffer_ord ASSIGNING FIELD-SYMBOL(<buffer>).
        <buffer>-sord = <lfs_delete>-Sord.
        <buffer>-flag = 'D'.
        INSERT VALUE #( sord = <lfs_delete>-sord ) INTO TABLE mapped-sord.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
  DATA ls_failed LIKE LINE OF reported-sord.

  GET TIME STAMP FIELD DATA(lv_tsl).
    LOOP AT entities INTO DATA(ls_hdrUpd).
      SELECT * FROM zordhd_aat WHERE sord = @ls_hdrUpd-Sord
                                       INTO TABLE @DATA(lt_hdr) .
      IF sy-subrc EQ 0.
        LOOP AT lt_hdr ASSIGNING FIELD-SYMBOL(<lfs_olddata>).
        IF ls_hdrUpd-CustomerId <> <lfs_olddata>-customer_id AND
              ls_hdrUpd-CustomerId <> ' '.
            DATA(lv_customer_chg) = 'X'.
          ENDIF.

          IF ls_hdrUpd-VendorId <> <lfs_olddata>-Vendor_Id AND
              ls_hdrUpd-VendorId <> ' '.
            DATA(lv_vendor_chg) = 'X'.
          ENDIF.

          IF ls_hdrUpd-DeliveryCountry <> <lfs_olddata>-delivery_country AND
             ls_hdrUpd-DeliveryCountry <> ' '.
            DATA(lv_delivcountry_chg) = 'X'.
          ENDIF.

          IF ls_hdrUpd-Description <> <lfs_olddata>-Description AND
             ls_hdrUpd-Description <> ' '.
            DATA(lv_Description_chg) = 'X'.
          ENDIF.

          IF ls_hdrUpd-Remarks <> <lfs_olddata>-remarks  AND
              ls_hdrUpd-remarks <> ' '.
            DATA(lv_remarks_chg) = 'X'.
          ENDIF.


          IF ls_hdrUpd-OverallStatus <> <lfs_olddata>-overall_status AND
             ls_hdrUpd-overallstatus <> ' '.
            DATA(lv_status_chg) = 'X'.
          ENDIF.

          IF ls_hdrUpd-OrderConfDate <> <lfs_olddata>-order_conf_date AND
             ls_hdrUpd-OrderConfDate <> ' '.
            DATA(lv_OrderConfDate_chg) = 'X'.
          ENDIF.

          IF ls_hdrUpd-DeliveryDate <> <lfs_olddata>-delivery_date AND
             ls_hdrUpd-DeliveryDate <> ' '.
            DATA(lv_DeliveryDate_chg) = 'X'.
          ENDIF.

          IF lv_customer_chg = 'X' OR
             lv_vendor_chg = 'X' OR
             lv_delivcountry_chg = 'X' OR
             lv_Description_chg = 'X' OR
             lv_status_chg = 'X' OR
             lv_remarks_chg = 'X' OR
             lv_OrderConfDate_chg = 'X' OR
             lv_DeliveryDate_chg = 'X'.
            APPEND INITIAL LINE TO lcl_buffer=>mt_buffer_ord ASSIGNING FIELD-SYMBOL(<lfs_buffer>).
            <lfs_buffer>-sord  = <lfs_olddata>-sord.
            <lfs_buffer>-customer_id =  <lfs_olddata>-customer_id.
            <lfs_buffer>-vendor_id        = <lfs_olddata>-vendor_id.
            <lfs_buffer>-delivery_country = <lfs_olddata>-delivery_country.
            <lfs_buffer>-description      = <lfs_olddata>-description.
            <lfs_buffer>-overall_status   = <lfs_olddata>-overall_status.
            <lfs_buffer>-created_by       = <lfs_olddata>-created_by.
            <lfs_buffer>-created_at       = <lfs_olddata>-created_at.
            <lfs_buffer>-remarks          = <lfs_olddata>-remarks.
            <lfs_buffer>-order_conf_date          = <lfs_olddata>-order_conf_date.
            <lfs_buffer>-delivery_date          = <lfs_olddata>-delivery_date.
            <lfs_buffer>-last_changed_by  = sy-uname.
            <lfs_buffer>-last_changed_at  = lv_tsl.
            <lfs_buffer>-flag = 'U'.

            IF lv_customer_chg = 'X'.
              <lfs_buffer>-customer_id = ls_hdrUpd-CustomerId.
            ENDIF.

            IF lv_vendor_chg = 'X'.
              <lfs_buffer>-vendor_id = ls_hdrUpd-VendorId.
            ENDIF.

            IF lv_delivcountry_chg = 'X'.
              <lfs_buffer>-delivery_country = ls_hdrUpd-DeliveryCountry.
            ENDIF.

            IF lv_Description_chg = 'X'.
              <lfs_buffer>-description = ls_hdrUpd-Description.
            ENDIF.

            IF lv_status_chg = 'X'.
              <lfs_buffer>-overall_status = ls_hdrUpd-OverallStatus.
            ENDIF.

            IF lv_remarks_chg = 'X'.
              <lfs_buffer>-remarks = ls_hdrUpd-remarks.
            ENDIF.

            IF lv_orderconfdate_chg = 'X'.
              <lfs_buffer>-order_conf_date = ls_hdrUpd-orderconfdate.
            ENDIF.

            IF lv_deliverydate_chg = 'X'.
              <lfs_buffer>-delivery_date = ls_hdrUpd-DeliveryDate.
            ENDIF.

          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD read.
  LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
      SELECT * FROM zordhd_aat WHERE sord = @<lfs_keys>-Sord INTO TABLE @DATA(lt_result_tmp) .
      result = VALUE #( FOR ls_result_tmp IN lt_result_tmp
                        ( sord  = ls_result_tmp-sord
                        customerid =  ls_result_tmp-customer_id
      vendorid        = ls_result_tmp-vendor_id
      deliverycountry = ls_result_tmp-delivery_country
      description      = ls_result_tmp-description
      overallstatus   = ls_result_tmp-overall_status
      OrderConfDate   = ls_result_tmp-order_conf_date
      DeliveryDate    = ls_result_tmp-delivery_date
      Remarks         = ls_result_tmp-remarks
      createdby       = ls_result_tmp-created_by
      createdat       = ls_result_tmp-created_at
      lastchangedby  = ls_result_tmp-last_changed_by
      LastChangedAt  = ls_result_tmp-last_changed_at

    ) ).


    ENDLOOP.
  ENDMETHOD.

METHOD set_status.
  GET TIME STAMP FIELD DATA(lv_tsl).
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      SELECT * FROM zordhd_aat WHERE sord = @<lfs_keys>-Sord INTO TABLE @DATA(lt_result_tmp) .
      IF sy-subrc EQ 0.
        LOOP AT lt_result_tmp ASSIGNING FIELD-SYMBOL(<lfs_olddata>).
          APPEND INITIAL LINE TO lcl_buffer=>mt_buffer_ord ASSIGNING FIELD-SYMBOL(<lfs_buffer>).
          <lfs_result>-Sord = <lfs_olddata>-sord.
          <lfs_result>-%param-Sord = <lfs_olddata>-sord.
          <lfs_result>-%param-customerid =  <lfs_olddata>-customer_id.
          <lfs_result>-%param-vendorid        = <lfs_olddata>-vendor_id.
          <lfs_result>-%param-deliverycountry = <lfs_olddata>-delivery_country.
          <lfs_result>-%param-description      = <lfs_olddata>-description.
          <lfs_result>-%param-overallstatus   = 'R'.
          <lfs_result>-%param-createdby       = <lfs_olddata>-created_by.
          <lfs_result>-%param-createdat       = <lfs_olddata>-created_at.
          <lfs_result>-%param-lastchangedby  = <lfs_olddata>-last_changed_by.
          <lfs_result>-%param-OrderConfDate  = <lfs_olddata>-order_conf_date.
          <lfs_result>-%param-DeliveryDate  = <lfs_olddata>-delivery_date.
          <lfs_buffer> = CORRESPONDING #( <lfs_olddata> ).
          <lfs_buffer>-overall_status = 'R'.
          <lfs_buffer>-last_changed_by  = sy-uname.
            <lfs_buffer>-last_changed_at  = lv_tsl.
          <lfs_buffer>-flag = 'U'.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
ENDMETHOD.

  METHOD get_features.
    DATA: ls_result LIKE LINE OF result.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
      SELECT SINGLE * FROM zordhd_aat WHERE sord = @<lfs_keys>-Sord INTO @DATA(ls_result_tmp) .
      ls_result-%key = <lfs_keys>-Sord.
      ls_result-%features-%action-set_status = COND #( WHEN ls_result_tmp-overall_status = 'R'
                                                                    THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
            .
            APPEND ls_result TO result.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZI_ORDHRD_AAT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_ORDHRD_AAT IMPLEMENTATION.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD finalize.
  ENDMETHOD.

  METHOD save.
  DATA: lt_data_cr TYPE STANDARD TABLE OF zordhd_aat,
        lt_data_del TYPE STANDARD TABLE OF zordhd_aat,
        lt_data_upd TYPE STANDARD TABLE OF zordhd_aat.

    lt_data_cr = VALUE #(  FOR row IN lcl_buffer=>mt_buffer_ord WHERE  ( flag = 'C' ) (  row-data ) ).
    IF lt_data_cr IS NOT INITIAL.
      INSERT zordhd_aat FROM TABLE @lt_data_cr.
    ENDIF.

    lt_data_del = VALUE #( FOR row IN lcl_buffer=>mt_buffer_ord WHERE ( flag = 'D' ) ( row-data ) ).
    IF lt_data_del IS NOT INITIAL.
      DELETE zordhd_aat FROM TABLE @lt_data_del.
    ENDIF.

    lt_data_upd = VALUE #( FOR row IN lcl_buffer=>mt_buffer_ord WHERE ( flag = 'U' ) ( row-data ) ).
    IF lt_data_upd IS NOT INITIAL.
      UPDATE zordhd_aat FROM TABLE @lt_data_upd.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
