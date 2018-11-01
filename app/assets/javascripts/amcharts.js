//= require amcharts/amcharts
//= require amcharts/serial
//= require amcharts/amstock
//= require amcharts/plugins/export/export.min
//= require amcharts/themes/light

function stockChart(elId, data) {
  var el = document.getElementById(elId);
  if (!el) return;
  for (var index = 0; index < data.length; index++) {
    var element = data[index]
    element.date = Date.parse(element.period)
    element.value = parseFloat(element.avg)
    element.low = parseFloat(element.low)
    element.high = parseFloat(element.high)
    element.open = element.low
    element.close = element.high
  }
  var chart = AmCharts.makeChart(elId, {
    "type": "stock",
    "theme": "light",
    "dataSets": [ {
      "fieldMappings": [ {
        "fromField": "open",
        "toField": "open"
      }, {
        "fromField": "close",
        "toField": "close"
      }, {
        "fromField": "high",
        "toField": "high"
      }, {
        "fromField": "low",
        "toField": "low"
      }, {
        "fromField": "volume",
        "toField": "volume"
      }, {
        "fromField": "value",
        "toField": "value"
      } ],
      "dataProvider": data,
      "categoryField": "date"
    } ],
    "balloon": {
      "horizontalPadding": 13
    },
    "panels": [ {
      "title": "Price",
      "showCategoryAxis": false,
      "percentHeight": 70,
      "stockGraphs": [{
        "id": "g1",
        "type": "candlestick",
        "openField": "open",
        "closeField": "close",
        "highField": "high",
        "lowField": "low",
        "valueField": "close",
        "lineColor": "#7f8da9",
        "fillColors": "#7f8da9",
        "negativeLineColor": "#db4c3c",
        "negativeFillColors": "#db4c3c",
        "fillAlphas": 1,
        "balloonText": "open:<b>[[open]]</b><br>close:<b>[[close]]</b><br>low:<b>[[low]]</b><br>high:<b>[[high]]</b>",
        "useDataSetColors": false
      },{ 
        "id": "g2",
        "valueField": "value",
        "type": "smoothedLine",
        "lineThickness": 2,
        "bullet": "round",
        "lineColor": "#b0de09",
        "bulletColor": "#b0de09",
        "balloonText": "average: <b>[[value]]",
        "useDataSetColors": false
        }]
    },{
      "title": "Volume",
      "percentHeight": 30,
      "stockGraphs": [ {
        "valueField": "volume",
        "type": "column",
        "cornerRadiusTop": 2,
        "fillAlphas": 1
      } ],
      "stockLegend": {
        "valueTextRegular": " ",
        "markerType": "none"
      }
    } ],
    "pathToImages": "/amcharts/", // required for grips
    "chartScrollbarSettings": {
      "graph": "g1",
      "usePeriod": "10mm",
      "position": "top"
    },
    "panelsSettings": {
      "panEventsEnabled": true
    },
    "cursorSettings": {
      "valueBalloonsEnabled": true
    },
    "periodSelector": {
      "position": "top",
      "periods": [ {
        "period": "DD",
        "count": 10,
        "selected": true,
        "label": "10 days"
      }, {
        "period": "MM",
        "count": 1,
        "label": "1 month"
      }, {
        "period": "YYYY",
        "count": 1,
        "label": "1 year"
      }, {
        "period": "YTD",
        "label": "YTD"
      }, {
        "period": "MAX",
        "label": "MAX"
      } ]
    }
  } );
}