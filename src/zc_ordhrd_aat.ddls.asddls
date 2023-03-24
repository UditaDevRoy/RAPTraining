@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View'
define root view entity ZC_ORDHRD_AAT
  as projection on ZI_ORDHRD_AAT
{
      @UI: {
      lineItem: [ { position: 10, importance: #HIGH, label: 'Sales Order' } ],
      identification: [ { position: 10, label: 'Sales Order [1,...,99999999]' } ] }
      @Search.defaultSearchElement: true
  key Sord,
      @UI: {
      lineItem: [ { position: 30, importance: #HIGH, label: 'Customer' } ],
      identification: [ { position: 30 } ],
      selectionField: [ { position: 30 } ] }
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Customer', element: 'CustomerID' } }]
      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      CustomerId,
      @UI: {
      lineItem: [ { position: 60, importance: #HIGH, label: 'Vendor' } ],
      identification: [ { position: 60 } ],
      selectionField: [ { position: 60 } ] }
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Agency', element: 'AgencyID' } }]
      @ObjectModel.text.element: ['Vendor']
      @Search.defaultSearchElement: true
      VendorId,
      @UI: {
      lineItem: [ { position: 80, importance: #HIGH, label: 'Country' } ],
      identification: [ { position: 80 } ],
      selectionField: [ { position: 80 } ] }
      @Consumption.valueHelpDefinition: [{ entity : {name: 'I_Country', element: 'Country' } }]
      @ObjectModel.text.element: ['Country']
      @Search.defaultSearchElement: true
      DeliveryCountry,
      Description,
      OverallStatus,
      OrderConfDate,
      DeliveryDate,
      Remarks,
      @UI.hidden: true
      CreatedBy,
      @UI.hidden: true
      CreatedAt,
      @UI.hidden: true
      LastChangedBy,
      @UI.hidden: true
      LastChangedAt,
      /* Associations */
      _Agency,
      _Customer
}
