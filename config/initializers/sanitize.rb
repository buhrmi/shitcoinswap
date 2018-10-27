module Sanitize::Config
  WHITELISTED = RELAXED.dup
  WHITELISTED[:elements] = WHITELISTED[:elements].dup << 'iframe'
  WHITELISTED[:attributes] = WHITELISTED[:attributes].dup
  WHITELISTED[:attributes]['iframe'] = ['width', 'height', 'src', 'frameborder', 'allow', 'allowfullscreen']
  WHITELISTED[:protocols] = WHITELISTED[:protocols].dup
  WHITELISTED[:protocols]['iframe'] = ['https']
end