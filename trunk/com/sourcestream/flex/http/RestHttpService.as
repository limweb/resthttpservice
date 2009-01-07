/*
 * The MIT License
 *
 * Copyright (c) 2008
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 * http://cava.unog.ch
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.sourcestream.flex.http
{
    import mx.utils.StringUtil;
    import flash.events.EventDispatcher;
    import flash.events.ProgressEvent;
    import flash.events.Event;
    import flash.net.Socket;

    // result event is fired when the web service's response is received
    [Event(name="result", type="com.sourcestream.flex.http.HttpEvent")]

    /**
     * Similar to Flex's HTTP service component but adds support for all HTTP methods.
     */
    public class RestHttpService extends EventDispatcher
    {
        public static const EVENT_DATA_RECEIVED:String = "result";

        public static const METHOD_GET:String = "GET";
        public static const METHOD_POST:String = "POST";
        public static const METHOD_PUT:String = "PUT";
        public static const METHOD_DELETE:String = "DELETE";
        public static const METHOD_HEAD:String = "HEAD";
        public static const METHOD_OPTIONS:String = "OPTIONS";

        private static const DAYS:Array = new Array("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
        private static const MONTHS:Array = new Array("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep",
                "Oct", "Nov", "Dec");

        private var socket:Socket;
        private var _host:String;
        private var _port:String;
        private var _method:String;
        private var _uri:String;
        private var _body:String;
        private var _contentType:String = "text/plain";

        /**
         * Constructs a new REST HTTP service object.
         *
         * @param host Web service provider to which this class should connect
         * @param port Port on which to connect to the host
         */
        public function RestHttpService(host:String=null, port:String=null)
        {
            createSocket();
            _host = host;
            _port = port;
        }

        /**
         * Gets the address of the web service provider.
         *
         * @return Web service provider
         */
        public function get host():String
        {
            return _host;
        }

        /**
         * Sets the address of the web service provider.
         *
         * @param host Web service provider
         */
        public function set host(host:String):void
        {
            _host = host;
        }

        /**
         * Gets the port on which the web service provider is listening.
         *
         * @return Port on web service provider
         */
        public function get port():String
        {
            return _port;
        }

        /**
         * Sets the port on which the web service provider is listening.
         *
         * @param port Port on web service provider
         */
        public function set port(port:String):void
        {
            _port = port;
        }

        /**
         * Gets the HTTP method to be used by this service (GET, POST, PUT, DELETE, HEAD, OPTIONS).
         *
         * @return HTTP method
         */
        [Inspectable(defaultValue="GET", enumeration="GET,POST,PUT,DELETE,HEAD,OPTIONS")]
        public function get method():String
        {
            return _method;
        }

        /**
         * Sets the HTTP method to be used by this service (GET, POST, PUT, DELETE, HEAD, OPTIONS).
         *
         * @param method HTTP method
         */
        public function set method(method:String):void
        {
            _method = method;
        }

        public function get uri():String
        {
            return _uri;
        }

        public function set uri(uri:String):void
        {
            _uri = uri;
        }

        public function get contentType():String
        {
            return _contentType;
        }

        public function set contentType(contentType:String):void
        {
            _contentType = contentType;
        }

        private function createSocket():void
        {
            if (socket == null && _host != null && _port != null)
            {
                socket = new Socket();
                socket.addEventListener(Event.CONNECT, connectHandler);
                socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
            }
        }

        public function doGet(uri:String):void
        {
            sendRequest(METHOD_GET, uri);
        }

        public function doPost(uri:String, body:String):void
        {
            sendRequest(METHOD_POST, uri, body);
        }

        public function doPut(uri:String, body:String):void
        {
            sendRequest(METHOD_PUT, uri, body);
        }

        public function doDelete(uri:String):void
        {
            sendRequest(METHOD_DELETE, uri);
        }

        public function doHead(uri:String):void
        {
            sendRequest(METHOD_HEAD, uri, _body);
        }

        public function doOptions(uri:String, body:String=""):void
        {
            sendRequest(METHOD_OPTIONS, uri, body);
        }

        public function send(body:String=null):void
        {
            _body = body;
            createSocket();
            socket.connect(_host, parseInt(_port));
        }

        private function sendRequest(method:String, uri:String, body:String=""):void
        {
            createSocket();
            socket.connect(_host, parseInt(_port));

            _method = method;
            _uri = uri;
            _body = body;
        }

        private function connectHandler(event:Event):void
        {
            var requestLine:String = _method + " " + _uri + " HTTP/1.0\n";

            var now:Date = new Date();
            var headers:String = "Date: " + DAYS[now.day] + ", " + now.date + " " + MONTHS[now.month] + " " +
                now.fullYear + " " + now.hours + ":" + now.minutes + ":" + now.seconds + "\n";
            headers += "Content-Type: " + _contentType + "\n";
            headers += "Content-Length: " + _body.length + "\n";

            socket.writeUTFBytes(requestLine + headers + "\n" + _body);
            socket.flush();
        }

        private function dataHandler(event:ProgressEvent):void
        {
            var rawResponse:String = socket.readUTFBytes(event.bytesLoaded);
            var lines:Array = rawResponse.split("\n");

            var isFirstLine:Boolean = true;
            var isBody:Boolean = false;
            var statusCode:int;
            var statusMessage:String;
            var headers:Object = new Object();
            var body:String;

            for each (var line:String in lines)
            {
                if (isFirstLine)
                {
                    var startStatusCode:int = line.indexOf(" ");
                    var endStatusCode:int = line.indexOf(" ", startStatusCode+1);
                    statusCode = parseInt(line.substr(startStatusCode, endStatusCode));
                    statusMessage = StringUtil.trim(line.substr(endStatusCode+1));
                    isFirstLine = false;
                }
                else if (StringUtil.trim(line) == "")
                {
                    isBody = true; // blank line separates headers from body
                }
                else if (isBody)
                {
                    body += line;
                }
                else // headers
                {
                    var colonIndex:int = line.indexOf(":");
                    var headerName:String = line.substr(0, colonIndex);
                    var headerValue:String = line.substr(colonIndex+1);
                    headers[headerName] = StringUtil.trim(headerValue);
                }
            }

            var httpEvent:HttpEvent = new HttpEvent(EVENT_DATA_RECEIVED);
            httpEvent.data = rawResponse;
            httpEvent.response = new HttpResponse(statusCode, statusMessage, headers, body);
            dispatchEvent(httpEvent);
        }
    }
}
