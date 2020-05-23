defmodule Observer.Common.HTTPComparisonTest do
  use BeholdWeb.ConnCase
  alias Observer.Common.HTTPComparison

  test "check_return_value/2 returns true if value is present", _ do
    {resp, _val} = HTTPComparison.check_return_value(%{body: "<div>foobar</div>"}, "foobar")
    assert resp == true
  end

  test "check_return_value/2 returns false if value is not present", _ do
    {resp, _val} = HTTPComparison.check_return_value(%{body: "<div>foobar</div>"}, "<a>")
    assert resp == false
  end

  test "check_return_value/2 returns error if error", _ do
    {resp, val} = HTTPComparison.check_return_value("foobar", "foobar")
    assert resp == false
    assert val == "error"
  end

  test "check_return_value/2 handles long values elegantly", _ do
    body =
    """
      <!DOCTYPE html><html lang="en"><head><link rel="preload" href="/frontend_latest/core.2de630fb.js" as="script" crossorigin="use-credentials"><link rel="preload" href="/static/fonts/roboto/Roboto-Regular.woff2" as="font" crossorigin><link rel="preload" href="/static/fonts/roboto/Roboto-Medium.woff2" as="font" crossorigin><meta charset="utf-8"><link rel="manifest" href="/manifest.json" crossorigin="use-credentials"><link rel="icon" href="/static/icons/favicon.ico"><meta name="viewport" content="width=device-width,user-scalable=no"><style>body{font-family:Roboto,sans-serif;-moz-osx-font-smoothing:grayscale;-webkit-font-smoothing:antialiased;font-weight:400;margin:0;padding:0;height:100vh}</style><title>Home Assistant</title><link rel="apple-touch-icon" sizes="180x180" href="/static/icons/favicon-apple-180x180.png"><link rel="mask-icon" href="/static/icons/mask-icon.svg" color="#03a9f4"><meta name="apple-itunes-app" content="app-id=1099568401"><meta name="apple-mobile-web-app-capable" content="yes"><meta name="msapplication-square70x70logo" content="/static/icons/tile-win-70x70.png"><meta name="msapplication-square150x150logo" content="/static/icons/tile-win-150x150.png"><meta name="msapplication-wide310x150logo" content="/static/icons/tile-win-310x150.png"><meta name="msapplication-square310x310logo" content="/static/icons/tile-win-310x310.png"><meta name="msapplication-TileColor" content="#03a9f4ff"><meta name="mobile-web-app-capable" content="yes"><meta name="referrer" content="same-origin"><meta name="theme-color" content="#03A9F4"><style>#ha-init-skeleton::before{display:block;content:"";height:112px;background-color:#03A9F4}</style></head><body><div id="ha-init-skeleton"></div><home-assistant></home-assistant><script>function _ls(e){var t=document.documentElement,s=t.insertBefore(document.createElement("script"),t.lastChild);s.defer=!0,s.src=e}window.Polymer={lazyRegister:!0,useNativeCSSProperties:!0,dom:"shadow",suppressTemplateNotifications:!0,suppressBindingNotifications:!0},"customElements"in window&&"content"in document.createElement("template")||document.write("<script src='/static/polyfills/webcomponents-bundle.js'><\/script>");var isS101=/\s+Version\/10\.1(?:\.\d+)?\s+Safari\//.test(navigator.userAgent)</script><script type="module" crossorigin="use-credentials">import "/frontend_latest/core.2de630fb.js";
        import "/frontend_latest/app.714f6631.js";
        import "/frontend_latest/hass-icons.491db358.js";
        window.customPanelJS = "/frontend_latest/custom-panel.7a021869.js";</script><script nomodule>(function() {
          // // Safari 10.1 supports type=module but ignores nomodule, so we add this check.
          if (!isS101) {
            window.customPanelJS = "/frontend_es5/custom-panel.c5e5b82f.js";
            _ls("/static/polyfills/custom-elements-es5-adapter.js");
            _ls("/frontend_es5/compatibility.a79f1f44.js");
            _ls("/frontend_es5/core.9eab0e85.js");
            _ls("/frontend_es5/app.7201221c.js");
            _ls("/frontend_es5/hass-icons.95da698b.js");
            }
        })();</script></body></html>
    """
    {resp, val} = HTTPComparison.check_return_value(%{body: body}, "Home Assistant")
    assert resp == true
    assert val == "\"  <!DOCTYPE html><html lang=\\\"en\\\"><head><link rel=\\\"preload\\\" href=\\\"/frontend_latest/core.2de630fb.js\\\" as=\\\"script\\\" crossorigin=\\\"use-credentials\\\"><link rel=\\\"preload\\\" href=\\\"/static/fonts/roboto/Roboto-Regular.woff2\\\" as=\\\"font\\\" crossorigin><link rel=\\\"preload\\\"\"..."
  end

  test "format_response_body_for_database/1 truncates correctly", _ do
    body =
    """
      <!DOCTYPE html><html lang="en"><head><link rel="preload" href="/frontend_latest/core.2de630fb.js" as="script" crossorigin="use-credentials"><link rel="preload" href="/static/fonts/roboto/Roboto-Regular.woff2" as="font" crossorigin><link rel="preload" href="/static/fonts/roboto/Roboto-Medium.woff2" as="font" crossorigin><meta charset="utf-8"><link rel="manifest" href="/manifest.json" crossorigin="use-credentials"><link rel="icon" href="/static/icons/favicon.ico"><meta name="viewport" content="width=device-width,user-scalable=no"><style>body{font-family:Roboto,sans-serif;-moz-osx-font-smoothing:grayscale;-webkit-font-smoothing:antialiased;font-weight:400;margin:0;padding:0;height:100vh}</style><title>Home Assistant</title><link rel="apple-touch-icon" sizes="180x180" href="/static/icons/favicon-apple-180x180.png"><link rel="mask-icon" href="/static/icons/mask-icon.svg" color="#03a9f4"><meta name="apple-itunes-app" content="app-id=1099568401"><meta name="apple-mobile-web-app-capable" content="yes"><meta name="msapplication-square70x70logo" content="/static/icons/tile-win-70x70.png"><meta name="msapplication-square150x150logo" content="/static/icons/tile-win-150x150.png"><meta name="msapplication-wide310x150logo" content="/static/icons/tile-win-310x150.png"><meta name="msapplication-square310x310logo" content="/static/icons/tile-win-310x310.png"><meta name="msapplication-TileColor" content="#03a9f4ff"><meta name="mobile-web-app-capable" content="yes"><meta name="referrer" content="same-origin"><meta name="theme-color" content="#03A9F4"><style>#ha-init-skeleton::before{display:block;content:"";height:112px;background-color:#03A9F4}</style></head><body><div id="ha-init-skeleton"></div><home-assistant></home-assistant><script>function _ls(e){var t=document.documentElement,s=t.insertBefore(document.createElement("script"),t.lastChild);s.defer=!0,s.src=e}window.Polymer={lazyRegister:!0,useNativeCSSProperties:!0,dom:"shadow",suppressTemplateNotifications:!0,suppressBindingNotifications:!0},"customElements"in window&&"content"in document.createElement("template")||document.write("<script src='/static/polyfills/webcomponents-bundle.js'><\/script>");var isS101=/\s+Version\/10\.1(?:\.\d+)?\s+Safari\//.test(navigator.userAgent)</script><script type="module" crossorigin="use-credentials">import "/frontend_latest/core.2de630fb.js";
        import "/frontend_latest/app.714f6631.js";
        import "/frontend_latest/hass-icons.491db358.js";
        window.customPanelJS = "/frontend_latest/custom-panel.7a021869.js";</script><script nomodule>(function() {
          // // Safari 10.1 supports type=module but ignores nomodule, so we add this check.
          if (!isS101) {
            window.customPanelJS = "/frontend_es5/custom-panel.c5e5b82f.js";
            _ls("/static/polyfills/custom-elements-es5-adapter.js");
            _ls("/frontend_es5/compatibility.a79f1f44.js");
            _ls("/frontend_es5/core.9eab0e85.js");
            _ls("/frontend_es5/app.7201221c.js");
            _ls("/frontend_es5/hass-icons.95da698b.js");
            }
        })();</script></body></html>
    """
    val = HTTPComparison.format_response_body_for_database(body)
    assert val == "\"  <!DOCTYPE html><html lang=\\\"en\\\"><head><link rel=\\\"preload\\\" href=\\\"/frontend_latest/core.2de630fb.js\\\" as=\\\"script\\\" crossorigin=\\\"use-credentials\\\"><link rel=\\\"preload\\\" href=\\\"/static/fonts/roboto/Roboto-Regular.woff2\\\" as=\\\"font\\\" crossorigin><link rel=\\\"preload\\\"\"..."
  end
  
  test "format_response_body_for_database/1 does not truncate small strings", _ do
    body =
    """
      I like turtles
    """
    val = HTTPComparison.format_response_body_for_database(body)
    assert val == "\"  I like turtles\\n\""
  end
end