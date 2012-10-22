Changes brought to the original Away release:

 * HoverController
	* we allow immediate changes of position
 * VideoTexture
	* we can change the player
	* we implemented smart updates: only update texture if player's current frame number has changed
	* we report the actual number of updated frames per second
 * IVideoPlayer
	* we can specify the number of frames per second (as we could specify width and height), called fps
	* we have access to the current frame number
 * SimpleVideoPlayer
	* implementation of new methods specified by IVideoPlayer
	* we can play videos streamed via RTMP
	* we now indicate when video is ready to be played (requires that connection to streaming server has been established)
	* separated NetStream and NetConnection handling from this class and creation of NetStreamsManager


==============================

Copyright 2011 The Away3D Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.