/*
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
 */

package io.cordova.hellocordova;

import android.os.Bundle;
import org.apache.cordova.*;

public class HelloCordova extends CordovaActivity 
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        super.init();
    }

    @Override
    public void init() {
        // Set by <content src="index.html" /> in config.xml
        jp.wizcorp.spellcaster.Spellcaster spellcaster = new jp.wizcorp.spellcaster.Spellcaster();
        spellcaster.init(this, Config.getStartUrl(), appView);
    }

    @Override
    public void init(org.apache.cordova.CordovaWebView webView,
                     org.apache.cordova.CordovaWebViewClient webViewClient,
                     org.apache.cordova.CordovaChromeClient webChromeClient) {
        super.init(webView, webViewClient, webChromeClient);

        // Set by <content src="index.html" /> in config.xml
        jp.wizcorp.spellcaster.Spellcaster spellcaster = new jp.wizcorp.spellcaster.Spellcaster();
        spellcaster.init(this, Config.getStartUrl(), webView);
    }
}

