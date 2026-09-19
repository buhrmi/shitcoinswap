<script>
  import Highcharts from '~/lib/highcharts'
  import { onMount, untrack } from 'svelte';
  import { formatAmount } from '~/lib/format'

  // Use the browser's timezone so Highcharts.dateFormat renders local time
  // instead of the default UTC.
  Highcharts.setOptions({
    time: {
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone
    }
  })

  const {
    data = [],
    quote_asset,
    ui = true,
    autoExtend = true,
    css
  } = $props()

  let chart = null
  let crosshairLine = null
  let crosshairDot = null

  let hoverDate = $state('')
  let hoverPrice = $state('')

  let lastDate = $derived(Highcharts.dateFormat('%b %e, %Y', data[data.length - 1][0]))
  let lastPrice = $derived(data[data.length - 1]?.[1])

  let range = $state('All')

  const RANGE_MS = {
    Hour: 60 * 60 * 1000,
    Day: 24 * 60 * 60 * 1000,
    Week: 7 * 24 * 60 * 60 * 1000,
    Month: 30 * 24 * 60 * 60 * 1000,
    Year: 365 * 24 * 60 * 60 * 1000
  }

  function zoomTo(r) {
    range = r
    if (!chart) return
    const series = chart.series[0]
    if (!series || !series.data.length) return

    const xAxis = chart.xAxis[0]
    const last = series.data[series.data.length - 1].x

    if (r === 'All') {
      xAxis.setExtremes(series.data[0].x, last)
    } else {
      xAxis.setExtremes(new Date().getTime() - RANGE_MS[r], last)
    }
  }

  // Get the exact Y on the rendered SVG spline at a given chartX coordinate.
  // Uses binary search on getPointAtLength for pixel-perfect matching.
  function getSplineYAtX(pathEl, targetX, plotLeft) {
    if (!pathEl) return null
    const len = pathEl.getTotalLength()
    if (len === 0) return null

    // Binary search along the path length to find the point at targetX
    let lo = 0, hi = len
    for (let iter = 0; iter < 20; iter++) {
      const mid = (lo + hi) / 2
      const pt = pathEl.getPointAtLength(mid)
      if (pt.x < targetX) lo = mid
      else hi = mid
    }
    return pathEl.getPointAtLength((lo + hi) / 2)
  }

  // Handle both mouse and touch events — normalize to the first touch
  // point if it's a TouchEvent, otherwise pass the event directly.
  function normalizeEvent(e) {
    if (e.touches && e.touches.length > 0) return e.touches[0]
    return e
  }

  function updateCrosshair(e) {
    if (!chart) return
    const pos = chart.pointer.normalize(normalizeEvent(e))
    const x = pos.chartX
    const plotTop = chart.plotTop
    const plotBottom = chart.plotTop + chart.plotHeight
    const xAxis = chart.xAxis[0]
    const xVal = xAxis.toValue(x)
    const priceSeries = chart.series[0]

    const points = priceSeries.points
    const pathEl = priceSeries.graph?.element
    const svgPt = getSplineYAtX(pathEl, x, chart.plotLeft)

    if (svgPt) {
      const y = svgPt.y

      // Update or create crosshair line
      if (!crosshairLine) {
        crosshairLine = chart.renderer.path(['M', x, plotTop, 'L', x, plotBottom])
          .attr({
            stroke: 'rgba(255,255,255,0.25)',
            'stroke-width': 1,
            'stroke-dasharray': '4,4',
            zIndex: 5
          })
          .add()
      } else {
        crosshairLine.attr({ d: ['M', x, plotTop, 'L', x, plotBottom] })
      }

      // Update or create dot at interpolated spline position
      if (!crosshairDot) {
        crosshairDot = chart.renderer.circle(x, y, 5)
          .attr({
            fill: '#6c5ce7',
            zIndex: 6
          })
          .add()
      } else {
        crosshairDot.attr({ cx: x, cy: y })
      }

      // Let Highcharts find the nearest discrete data point for the displayed price
      const nearest = priceSeries.searchPoint(pos, true)

      // Update Svelte state for tooltip display
      hoverDate = Highcharts.dateFormat('%b %e, %Y %H:%M', xVal)
      if (nearest?.y != null) {
        hoverPrice = nearest.y.toFixed()
      }
    }
  }

  function hideCrosshair() {
    if (crosshairLine) {
      crosshairLine.destroy()
      crosshairLine = null
    }
    if (crosshairDot) {
      crosshairDot.destroy()
      crosshairDot = null
    }
    hoverDate = ''
    hoverPrice = ''
  }

  onMount(function() {
    chart = Highcharts.chart('chart', {
      credits: {
        enabled: false
      },
      accessibility: {
        enabled: false
      },
      title: {
        text: null
      },
      chart: {
        backgroundColor: 'transparent',
        spacing: [0, 0, 0, 0],
        margin: [0,0,3,0],
        panning: { enabled: false }
      },
      xAxis: {
        minRange: 1, 
        type: 'datetime',
        visible: false,
      },
      yAxis: {
        visible: false,
      },
      legend: {
        enabled: false
      },
      tooltip: {
        enabled: false,
        followTouchMove: false
      },
      series: [{
        type: 'spline',
        name: 'Price',
        data,
        color: '#6c5ce7',
        fillColor: 'transparent',
        lineWidth: 2,
        marker: {
          enabled: false,
          states: {
            hover: {
              enabled: false
            }
          }
        },
        states: {
          hover: {
            halo: {
              enabled: true
            }
          }
        },
        threshold: null
      }]
    })

    const container = document.getElementById('chart')
    container.addEventListener('mousemove', updateCrosshair)
    container.addEventListener('mouseleave', hideCrosshair)
    container.addEventListener('touchmove', updateCrosshair)
    container.addEventListener('touchend', hideCrosshair)

  })

  
  let extendedData = $state(null)
  function setExtendedData() {
    if (data.length == 0) return
    const lastValue = data[data.length - 1][1]  
    if (autoExtend) {
      extendedData = [...data, [new Date().getTime(), lastValue]]
    }
    else {
      extendedData = data
    }
  }

  $effect(setExtendedData)

  onMount(function() {
    const interval = setInterval(setExtendedData, 10000)
    return () => clearInterval(interval)
  })
  
  $effect(() => {
    if (!extendedData) return
    untrack(() => {
      chart.series[0].setData(extendedData);
      zoomTo(range)
    })
  })
</script>


{#if ui}
  <div class="price">
    <div class="text-gray text-sm">
      {#if hoverDate}
        {hoverDate}
      {:else}
        Current Sell Price
      {/if}
    </div>
    <span class="text-2xl font-semibold">
      {formatAmount(hoverPrice || lastPrice, quote_asset)}
    </span>
  </div>
{/if}


<div id="chart" class="full w-full h-full relative {css}" style="touch-action: pan-y;">
</div>

{#if ui}
<div class="flex gap-2 w-full">
  <button class="btn secondary small flex-1" class:active={range === 'Hour'} onclick={() => zoomTo('Hour')}>
    H
  </button>
  <button class="btn secondary small flex-1" class:active={range === 'Day'} onclick={() => zoomTo('Day')}>
    D
  </button>
  <button class="btn secondary small flex-1" class:active={range === 'Week'} onclick={() => zoomTo('Week')}>
    W
  </button>
  <button class="btn secondary small flex-1" class:active={range === 'Month'} onclick={() => zoomTo('Month')}>
    M
  </button>
  <button class="btn secondary small flex-1" class:active={range === 'Year'} onclick={() => zoomTo('Year')}>
    Y
  </button>
  <button class="btn secondary small flex-1" class:active={range === 'All'} onclick={() => zoomTo('All')}>
    All
  </button>
</div>
{/if}
