package ValveLib.Controls
{
   import flash.display.MovieClip;
   import flash.media.*;
   import flash.net.*;
   import flash.events.NetStatusEvent;

   public class VideoController
   {

      public function VideoController(param1:int) {
         super();
         this.vecVideoContainer = new Vector.<MovieClip>(param1);
         this.vecVideoPlaying = new Vector.<Boolean>(param1);
         this.vecVideoFilename = new Vector.<String>(param1);
         this.vecVideoNetStream = new Vector.<NetStream>(param1);
         this.vecVideoTimeInterval = new Vector.<Number>(param1);
         this.vecVideo = new Vector.<Video>(param1);
         this.onStartFunc = null;
         var _loc2_:* = 0;
         while(_loc2_ < param1)
         {
            this.vecVideoContainer[_loc2_] = null;
            this.vecVideoPlaying[_loc2_] = false;
            _loc2_++;
         }
      }

      private var vecVideoContainer:Vector.<MovieClip>;

      private var vecVideoPlaying:Vector.<Boolean>;

      private var vecVideoFilename:Vector.<String>;

      private var vecVideoNetStream:Vector.<NetStream>;

      private var vecVideoTimeInterval:Vector.<Number>;

      private var vecVideo:Vector.<Video>;

      private var onStartFunc:Function;

      public var videoWidth:int = 256;

      public var videoHeight:int = 256;

      public function startVideo(param1:int, param2, param3:String) : * {

      	trace('I was asked to start '+param3);
         param3 = "videos/portraits/npc_dota_hero_antimage.usm";

         if(this.vecVideoPlaying[param1])
         {
            if(param3 == this.vecVideoFilename[param1])
            {
               return;
            }
            this.stopVideo(param1);
         }
         this.vecVideoContainer[param1] = param2;
         this.vecVideoFilename[param1] = param3;
         this.vecVideo[param1] = new Video(this.videoWidth,this.videoHeight);
         param2.visible = true;
         param2.videoParent.addChild(this.vecVideo[param1]);
         var _loc4_:NetConnection = new NetConnection();
         _loc4_.connect(null);
         this.vecVideoNetStream[param1] = new NetStream(_loc4_);
         this.vecVideo[param1].attachNetStream(this.vecVideoNetStream[param1]);
         //this.vecVideoNetStream[param1].loop = true;
         this.vecVideoNetStream[param1].bufferTime = 0.5;
         //this.vecVideoNetStream[param1].reloadThresholdTime = 0.3;
         this.vecVideoNetStream[param1].play(this.vecVideoFilename[param1]);
         this.vecVideoPlaying[param1] = true;
         this.vecVideoNetStream[param1].addEventListener(NetStatusEvent.NET_STATUS,this.VideoStatusHandler);
      }

      public function stopVideo(param1:int) : * {
         if(!this.vecVideoContainer[param1])
         {
            return;
         }
         this.vecVideoContainer[param1].visible = false;
         if(!this.vecVideoPlaying[param1])
         {
            return;
         }
         this.vecVideoPlaying[param1] = false;
         this.vecVideoNetStream[param1].close();
         if(this.vecVideo[param1] != null)
         {
            this.vecVideoContainer[param1].videoParent.removeChild(this.vecVideo[param1]);
            this.vecVideo[param1] = null;
         }
      }

      public function stopAllVideos() : * {
         var _loc1_:* = 0;
         while(_loc1_ < this.vecVideoNetStream.length)
         {
            this.stopVideo(_loc1_);
            _loc1_++;
         }
      }

      public function restartAllVideos() : * {
         var _loc1_:* = 0;
         while(_loc1_ < this.vecVideoNetStream.length)
         {
            if(this.vecVideoPlaying[_loc1_])
            {
               this.vecVideoNetStream[_loc1_].play(this.vecVideoFilename[_loc1_]);
            }
            _loc1_++;
         }
      }

      function checkVideoTime(param1:NetStream) : * {
      }

      public function VideoStatusHandler(param1:NetStatusEvent) : void {
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         if(param1.info.code == "NetStream.Play.Stop")
         {
            _loc2_ = 0;
            while(_loc2_ < this.vecVideoNetStream.length)
            {
               if(param1.target == this.vecVideoNetStream[_loc2_])
               {
                  if(this.vecVideoPlaying[_loc2_])
                  {
                     this.vecVideoNetStream[_loc2_].play(this.vecVideoFilename[_loc2_]);
                  }
               }
               _loc2_++;
            }
         }
         else if(param1.info.code == "NetStream.Play.Start")
         {
            if(this.onStartFunc != null)
            {
               _loc3_ = 0;
               while(_loc3_ < this.vecVideoNetStream.length)
               {
                  if(param1.target == this.vecVideoNetStream[_loc3_])
                  {
                     this.onStartFunc(_loc3_);
                     break;
                  }
                  _loc3_++;
               }
            }
         }

      }

      public function setOnStartFunc(param1:Function) : * {
         this.onStartFunc = param1;
      }
   }
}
