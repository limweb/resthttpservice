# Usage Instructions #

I plan to write detailed instructions eventually but this will have to suffice for now.

## Security Restrictions ##

The RestHttpService library uses sockets to overcome the limitations of Flex's HTTPService component. Unfortunately, the Flash security model restricts a Flex application from making socket connections to any server that does not explicitly permit such connections (excluding basic HTTP GET and POST requests). Prior to Flash version 9.0.124, in order to make a REST service available to a Flex socket client, the REST server just needed to expose a socket policy file named crossdomain.xml on the web root (unless the Security.loadPolicyFile() method is used to explicitly load a different file from another port). This policy file was accessed automatically by Flex before it attempted to open a socket. If the policy file was not available or did not grant access to the Flex application's domain, Flex would throw a "Security sandbox violation" error. Here is a very basic example of a crossdomain.xml file that allows access to all domains and ports:

```
<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
    <allow-access-from domain="*"/>
</cross-domain-policy>
```

The following policy file grants access on port 8080 to all Flex clients originating from the company.com domain:

```
<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
    <allow-access-from domain="*.company.com" to-ports="8080" secure="false"/>
</cross-domain-policy>
```

For detailed information regarding the format of the crossdomain.xml file and how to use it, see this article:

http://kb.adobe.com/selfservice/viewContent.do?externalId=tn_14213&sliceId=2

As mentioned above, prior to Flash 9.0.124, the policy file could be served by an HTTP server. Unfortunately, a socket server is now required. You can no longer grant access to Flex socket clients by just dropping a crossdomain.xml file in your web root. Since you can't use an HTTP server, a simple way to serve the policy file is to run a small daemon process, called a policy file server, on your REST server that does nothing more than listen for socket connections and serve the policy file from port 843. When a Flex application attempts to open a socket, Flash will automatically send a request to the policy file server containing the following contents: <pre><policy-file-request/></pre> The server should then respond with the contents of the crossdomain.xml file discussed above. You can learn more about how to set up a policy file server here:

http://www.adobe.com/devnet/flashplayer/articles/socket_policy_files.html

A free script that implements a simple policy file server is available here:

http://download.macromedia.com/pub/developer/flashpolicyd_v0.6.zip

If you'd prefer to listen for policy file requests on a port other than the default 843 (perhaps a port above 1024 so you don't have to run the policy server as root), your Flex application will need to make this call at startup:

```
Security.loadPolicyFile("xmlsocket://" + restServerName + ":" + socketPolicyPort);
```

UPDATE: If you'd like the RestHttpService to load the socket policy file automatically from a port other than 843, you can now set the policyFilePort property like this:

```
<rest:RestHttpService id="postService" server="localhost" port="8080" policyFilePort="1025" method="{RestHttpService.METHOD_POST}" resource="/books" contentType="application/xml" result="dataHandler(event)" fault="faultHandler(event)"/>
```

## Sample Code ##

To use the RestHttpService component, add it to your library path and invoke it from an MXML application. Here is some sample MXML to help get you started (you can download this sample MXML from the Downloads tab):

```
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" xmlns:rest="com.sourcestream.flex.http.*">

    <mx:Script><![CDATA[
        import mx.controls.Alert;

        import com.sourcestream.flex.http.HttpEvent;
        import com.sourcestream.flex.http.RestHttpService;

        function doPost():void
        {
            postService.send("<body>body of post request</body>");
        }

        function doPut():void
        {
            putService.send("<body>body of put request</body>");
        }

        function dataHandler(event:HttpEvent):void
        {
            Alert.show(event.response.statusCode + " (" + event.response.statusMessage + ")\n\n" + event.data);
        }

        function faultHandler(event:HttpEvent):void
        {
            Alert.show(event.response.statusCode + " (" + event.response.statusMessage + ")\n\n" + event.text);
        }

        /**
         * This method demonstrates how to invoke the RestHttpService class from ActionScript.
         */
        function actionScriptExample():void
        {
            //instantiate RestHttpService using host name or IP and port (add third paramater with value "true" for SSL)
            var restService:RestHttpService = new RestHttpService("localhost", 8080);

            //add a listener to be invoked when data is received
            restService.addEventListener(RestHttpService.EVENT_RESULT, dataHandler);

            //add a listener to be invoked when an error occurs
            restService.addEventListener(RestHttpService.EVENT_FAULT, faultHandler);

            //use appropriate do<Action>() method to call the REST service (i.e., for GET requests, use doGet() method)
            restService.doPost("/books", "<body>body of post request</body>", "application/xml");
            restService.doGet("/books/1");
            restService.doPut("/books/1", "<body>body of put request</body>", "application/xml");
            restService.doDelete("/books/1");
        }

        ]]>
    </mx:Script>

    <rest:RestHttpService id="postService" server="localhost" port="8080" method="{RestHttpService.METHOD_POST}" resource="/books" contentType="application/xml" result="dataHandler(event)" fault="faultHandler(event)"/>
    <rest:RestHttpService id="getService" server="localhost" port="8080" method="{RestHttpService.METHOD_GET}" resource="/books" result="dataHandler(event)" fault="faultHandler(event)"/>
    <rest:RestHttpService id="putService" server="localhost" port="8080" method="{RestHttpService.METHOD_PUT}" resource="/books/1" contentType="application/xml" result="dataHandler(event)" fault="faultHandler(event)"/>
    <rest:RestHttpService id="deleteService" server="localhost" port="8080" method="{RestHttpService.METHOD_DELETE}" resource="/books/1" result="dataHandler(event)" fault="faultHandler(event)"/>

    <mx:Button click="getService.send()" label="Get"/>
    <mx:Button click="doPost()" label="Post"/>
    <mx:Button click="doPut()" label="Put"/>
    <mx:Button click="deleteService.send()" label="Delete"/>

</mx:Application>
```

## Limitations ##

This service is under development and, therefore, does not yet support all HTTP features. For example, only text payloads are currently supported. Requests and responses carrying binary data will be supported in a future version. In addition, the HTTPS/TLS/SSL support is in the early stages of development and still experimental.