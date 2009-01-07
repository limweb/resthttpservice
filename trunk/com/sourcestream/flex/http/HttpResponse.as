package com.sourcestream.flex.http
{
    public class HttpResponse
    {
        private var _statusCode:int;
        private var _statusMessage:String;
        private var _headers:Object = new Object();
        private var _body:String = "";

        public function HttpResponse(statusCode:int, statusMessage:String, headers:Object, body:String="")
        {
            _statusCode = statusCode;
            _statusMessage = statusMessage;
            _headers = headers;
            _body = body;
        }

        public function get statusCode():int
        {
            return _statusCode;
        }

        public function get statusMessage():String
        {
            return _statusMessage;
        }

        public function get headers():Object
        {
            return _headers;
        }

        public function get body():String
        {
            return _body;
        }
    }
}