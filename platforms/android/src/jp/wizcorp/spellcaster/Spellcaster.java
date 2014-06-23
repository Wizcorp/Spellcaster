package jp.wizcorp.spellcaster;

import android.app.Activity;
import android.app.AlertDialog;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.util.Log;
import org.apache.cordova.CordovaWebView;

/*
 *
 *
 *
 *      ...                                        ..       ..                          .x+=:.        s
 *     88888hx    :                          x .d88"  x .d88"                          z`    ^%      :8
 *  d88888888888hxx   .d``                     5888R    5888R                              .   <k    .88                  .u    .
 *  8" ... `"*8888%`   @8Ne.   .u        .u     '888R    '888R         .         u        .@8Ned8"   :888ooo      .u     .d88B :@8c
 * !  "   ` .xnxx.     %8888:u@88N    ud8888.    888R     888R    .udR88N     us888u.   .@^%8888"  -*8888888   ud8888.  ="8888f8888r
 * X X   .H8888888%:    `888I  888. :888'8888.   888R     888R   <888'888k .@88 "8888" x88:  `)8b.   8888    :888'8888.   4888>'88"
 * X 'hn8888888*"   >    888I  888I d888 '88%"   888R     888R   9888 'Y"  9888  9888  8888N=*8888   8888    d888 '88%"   4888> '
 * X: `*88888%`     !    888I  888I 8888.+"      888R     888R   9888      9888  9888   %8"    R88   8888    8888.+"      4888>
 * '8h.. ``     ..x8>  uW888L  888' 8888L        888R     888R   9888      9888  9888    @8Wou 9%   .8888Lu= 8888L       .d888L .+
 *  `88888888888888f  '*88888Nu88P  '8888c. .+  .888B .  .888B . ?8888u../ 9888  9888  .888888P`    ^%888*   '8888c. .+  ^"8888*"
 *   '%8888888888*"   ~ '88888F`     "88888%    ^*888%   ^*888%   "8888P'  "888*""888" `   ^"F        'Y"     "88888%       "Y"
 *     ^"****""`        888 ^         "YP'       "%       "%       "P'     ^Y"   ^Y'                           "YP'
 *                      *8E
 *                      '8>
 *                       "
 *  For Cordova based applications
 *
 *  Author      : Ally Ogilvie | aogilvie@wizcorp.jp
 *  File        : Spellcaster.java
 *  Copyright   : Wizcorp 2013
 *
 */
public class Spellcaster {

    private static String TAG = "Spellcaster";
    private static int retryTimeout = 2000;
    private AlertDialog alertDialog = null;

    public void init(Activity act, String path, CordovaWebView webView) {

        // Check for active connection
        ConnectivityManager cm = (ConnectivityManager)act.getSystemService(act.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        boolean isConnected = activeNetwork != null && activeNetwork.isConnectedOrConnecting();

        if (isConnected) {
            // We have a connection, start the party!
            downloadAndBoot(path, webView);
        } else {

            // Get resource ids
            int connection_title_id = act.getResources().getIdentifier("connection_title", "string", act.getPackageName());
            int connection_message_id = act.getResources().getIdentifier("connection_message", "string", act.getPackageName());

            // Create dialog using dialog builder
            AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(act);

            // Set title
            alertDialogBuilder.setTitle(connection_title_id);

            // Set dialog message
            alertDialogBuilder
                    .setMessage(connection_message_id)
                    .setCancelable(false);

            // Create alert dialog
            alertDialog = alertDialogBuilder.create();

            // Show it
            alertDialog.show();

            // Retry connection with interval
            new asyncConnection(act, path, webView).execute();
        }
    }

    private class asyncConnection extends AsyncTask<Void, Void, Void> {

        private Activity act;
        private String path;
        private CordovaWebView webView;

        // Constructor
        public asyncConnection(Activity act, String path, CordovaWebView webView) {
            // Assign class vars
            this.act = act;
            this.path  = path;
            this.webView = webView;
        }

        @Override
        protected Void doInBackground(Void... params) {
            try {
                Thread.sleep(retryTimeout);
            } catch (InterruptedException e) {
            }
            return null;
        }

        @Override
        protected void onPostExecute(Void result) {
            // Check our connection
            ConnectivityManager cm = (ConnectivityManager)this.act.getSystemService(this.act.CONNECTIVITY_SERVICE);
            NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
            boolean isConnected = activeNetwork != null && activeNetwork.isConnectedOrConnecting();
            Log.d(TAG, "Connection isConnected: " + isConnected);
            if (isConnected) {
                if (alertDialog != null) {
                    alertDialog.hide();
                }
                downloadAndBoot(this.path, this.webView);
            } else {
                onRetry(this.act, this.path, this.webView);
            }
        }
    }

    private void onRetry(Activity act, String path, CordovaWebView webView) {
        // Retry connection with interval
        new asyncConnection(act, path, webView).execute();
    }

    private void downloadAndBoot(String path, CordovaWebView webView) {
        Log.d(TAG, "downloading and booting: " + path + " : " + webView);
        webView.loadUrl(path, 0);
    }
}
