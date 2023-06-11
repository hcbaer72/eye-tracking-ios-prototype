//
//  renderWebview.swift
//  Eyes Tracking
//
//  Created by holly on 6/10/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import WebKit


public class CustomWebViewRenderer : WebViewRenderer
{
    public CustomWebViewRenderer() : this(new WKWebViewConfiguration())
    {
    }

    public CustomWebViewRenderer(WKWebViewConfiguration config) : base(config)
    {
        WKUserContentController userController = config.UserContentController;
        WKWebView webView = new WKWebView(Frame, config);

        string viewportScript = "var meta = document.querySelector('meta[name=viewport]'); if (!meta) { meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); document.head.appendChild(meta); } meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');";
        WKUserScript viewportUserScript = new WKUserScript(new NSString(viewportScript), WKUserScriptInjectionTime.AtDocumentEnd, true);
        userController.AddUserScript(viewportUserScript);

        string styleScript = "var style = document.createElement('style'); style.innerHTML = 'html, body { max-width: 100%; overflow-x: hidden; }'; document.head.appendChild(style);";
        WKUserScript styleUserScript = new WKUserScript(new NSString(styleScript), WKUserScriptInjectionTime.AtDocumentEnd, true);
        userController.AddUserScript(styleUserScript);

        webView.Configuration.UserContentController = userController;
    }
}
