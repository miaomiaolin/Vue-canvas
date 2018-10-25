<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <meta name="keywords" content="miaomiao study">
    <meta name="description" content="miaomiao study">
    <meta name="_role" content="{<{.role}>}">
    <title>miaomiao</title>
    <% for (var i in htmlWebpackPlugin.options.cdn.css) { %><link href="<%= htmlWebpackPlugin.options.cdn.css[i] %>" rel="stylesheet"><% } %>
  </head>
  <body>
    <div id="app"></div>
    <!-- built files will be auto injected -->
    <% for (var i in htmlWebpackPlugin.options.cdn.js) { %><script src="<%= htmlWebpackPlugin.options.cdn.js[i] %>"></script><% } %>
  </body>
</html>
