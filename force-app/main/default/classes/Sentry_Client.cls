/**
 * Created by Jacob Mather <jmather@jmather.com> on 2019-03-18.
 */

public with sharing class Sentry_Client {
    private static Sentry_Dsn dsn = Sentry_Config.getDsn();

    public static void sendEventToSentry(String serializedEvent) {
        HttpRequest req = new HttpRequest();

        // you'll have to register a remote site for this url, but can probably just do a generic https://sentry.io...
        req.setEndpoint('https://sentry.io/api/' + dsn.projectId + '/store/');
        req.setHeader('content-type', 'application/json');

        addRequestHeaders(req);

        req.setMethod('POST');
        req.setBody(serializedEvent);

        Sentry_Log.logSentry('[Sentry_Client.sendEventToSentry] dsn: ' + dsn);
        Sentry_Log.logSentry('[Sentry_Client.sendEventToSentry] body: ' + serializedEvent);
        Sentry_Log.logSentry('[Sentry_Client.sendEventToSentry] request: ' + req);


        HttpResponse resp = new Http().send(req);

        Sentry_Log.logSentry('[Sentry_Client.sendEventToSentry] response: ' + resp);
    }

    private static void addRequestHeaders(HttpRequest req) {
        Map<String, String> headers = new Map<String, String> {
                'sentry_version' => '7',
                'sentry_sdk' => 'sentry.php',
                'sentry_key' => dsn.publicKey
        };

        if (dsn.privateKey != null) {
            headers.put('sentry_secret', dsn.privateKey);
        }

        String[] headerSets = new List<String>();
        for (String key : headers.keySet()) {
            headerSets.add(key + '=' + headers.get(key));
        }

        String header = 'Sentry ' + String.join(headerSets, ', ');

        Sentry_Log.logSentry('[Sentry_Client.addRequestHeaders] header: ' + header);

        req.setHeader('X-Sentry-Auth', header);
    }
}