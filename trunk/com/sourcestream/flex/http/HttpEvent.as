package com.sourcestream.flex.http
{
    import flash.events.DataEvent;

    public class HttpEvent extends DataEvent
    {
        public var response:HttpResponse;

        public function HttpEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}