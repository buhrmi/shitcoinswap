module Sanitize::Config
  WHITELISTED = RELAXED.dup
  WHITELISTED[:elements] = WHITELISTED[:elements].dup << 'iframe'
end