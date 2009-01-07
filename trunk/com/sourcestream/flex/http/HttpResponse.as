/*
 * The MIT License
 *
 * Copyright (c) 2008
 * Dustin R. Callaway
 * http://www.sourcestream.com/
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