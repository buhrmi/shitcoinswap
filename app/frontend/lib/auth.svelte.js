

export function authenticate(provider, flow = "login") {
  const width = 500;
  const height = 720;
  const left = (screen.width - width) / 2;
  const top = (screen.height - height) / 2;
  const windowFeatures = `width=${width},height=${height},left=${left},top=${top}`;
  
  window.open(`/session/new?provider=${provider}&flow=${flow}`, '_blank', windowFeatures);
}

