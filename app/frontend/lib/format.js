export function formatAmount(amount, quote_asset) {
  if (amount === undefined) return "unknown"
  
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: quote_asset.symbol,
  }).format(amount);
}

export function formatPrice(price) {
  return formatCurrency(price?.value, price?.quote_asset)
}

export function formatTimestamp(createdAt) {
    const date = new Date(createdAt)
    const seconds = Math.floor((Date.now() - date.getTime()) / 1000)

    if (seconds < 60) return 'now'
    const minutes = Math.floor(seconds / 60)
    if (minutes < 60) return `${minutes}m`
    const hours = Math.floor(minutes / 60)
    if (hours < 24) return `${hours}h`
    const days = Math.floor(hours / 24)
    if (days < 7) return `${days}d`
    return date.toLocaleDateString()
  }