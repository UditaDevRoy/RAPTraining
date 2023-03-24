@AbapCatalog.sqlViewName: 'ZORDHRD'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View'
@AbapCatalog.preserveKey: true
@UI:
{
 headerInfo:
  {
    typeName: 'Vendor',
    typeNamePlural: 'Vendors',
    title: { type: #STANDARD, value: 'Vendor' }
  }
 }
define root view ZI_ORDHRD_AAT
  as select from zordhd_aat
  /* Associations */
  association [0..1] to /DMO/I_Agency   as _Agency   on $projection.VendorId = _Agency.AgencyID
  association [0..1] to /DMO/I_Customer as _Customer on $projection.CustomerId = _Customer.CustomerID
{
      @UI.facet: [
              {
                id:       'Vendor',
                purpose:  #STANDARD,
                type:     #IDENTIFICATION_REFERENCE,
                label:    'Vendor Portal',
                position: 5 }
            ]


      @UI: {
      lineItem: [ { position: 5, importance: #HIGH, label: 'Sales Order' } ],
//      lineItem: [ { position: 10, importance: #HIGH, label: 'Sales Order' } ] }
//      identification: [ { position: 10, label: 'Sales Order [1,...,99999999]' } ],
     selectionField: [ { position: 10 }]  }
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Sales Order'  
  key zordhd_aat.sord             as Sord,
      @UI: {
          lineItem: [ { position: 30, importance: #HIGH, label: 'Customer' } ],
          identification: [ { position: 30 } ],
          selectionField: [ { position: 30 } ] }
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Customer', element: 'CustomerID' } }]
      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      zordhd_aat.customer_id      as CustomerId,
      @UI: {
         lineItem: [ { position: 50, importance: #HIGH, label: 'Vendor' } ],
         identification: [ { position: 50 } ],
         selectionField: [ { position: 50 } ] }
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Agency', element: 'AgencyID' } }]
      @ObjectModel.text.element: ['Vendor']
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Vendor'  
      zordhd_aat.vendor_id        as VendorId,
      @UI: {
        lineItem: [ { position: 70, importance: #HIGH, label: 'Delivery Country' } ],
        identification: [ { position: 70, label: 'Delivery Country' } ] }
        @Consumption.valueHelpDefinition: [{ entity : {name: 'I_Country', element: 'Country'  } }]
      zordhd_aat.delivery_country as DeliveryCountry,
      @UI: {
        lineItem: [ { position: 90, importance: #HIGH, label: 'Description' } ],
        identification: [ { position: 90, label: 'Description' } ] }
      zordhd_aat.description      as Description,
      @UI: {
      lineItem:       [ { position: 110, importance: #HIGH },
                        { type: #FOR_ACTION, dataAction: 'set_status', label: 'Change Status' } ],
      identification: [ { position: 110, label: 'Status [O(Open)|R(Released)|X(Canceled)]' } ]  }
      zordhd_aat.overall_status   as OverallStatus,
      @UI: {
        lineItem: [ { position: 115, importance: #HIGH, label: 'Order Conf Date' } ],
        identification: [ { position: 115, label: 'Order Conf Date' } ]}
      zordhd_aat.order_conf_date  as OrderConfDate,
      @UI: {
        lineItem: [ { position: 125, importance: #HIGH, label: 'Delivery Date' } ],
        identification: [ { position: 125, label: 'DeliveryDate' } ] }
      zordhd_aat.delivery_date    as DeliveryDate,
      @UI: {
        lineItem: [ { position: 130, importance: #HIGH, label: 'Remarks' } ],
        identification: [ { position: 130, label: 'Remarks' } ] }
      zordhd_aat.remarks          as Remarks,
      @UI.hidden: true
      @Semantics.user.createdBy: true
      zordhd_aat.created_by       as CreatedBy,
      @UI.hidden: true
      @Semantics.systemDateTime.createdAt: true
      zordhd_aat.created_at       as CreatedAt,
      @UI.hidden: true
      @Semantics.user.lastChangedBy: true
      zordhd_aat.last_changed_by  as LastChangedBy,
      @UI.hidden: true
      @Semantics.systemDateTime.lastChangedAt: true
      zordhd_aat.last_changed_at  as LastChangedAt,
      _Customer,
      _Agency

}
