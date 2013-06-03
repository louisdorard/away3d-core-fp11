# Away3D custom

## Changes brought to the original Away release

 * HoverController:
	* We allow immediate changes of position;
 * VideoTexture:
	* We can change the player;
	* We implemented smart updates: only update texture if player's current frame number has changed;
	* We report the actual number of updated frames per second;
 * IVideoPlayer:
	* We can specify the number of frames per second (as we could specify width and height), called fps;
	* We have access to the current frame number;
 * SimpleVideoPlayer:
	* Implementation of new methods specified by IVideoPlayer;
	* We can play videos streamed via RTMP;
	* We now indicate when video is ready to be played (requires that connection to streaming server has been established);
	* Separated NetStream and NetConnection handling from this class and creation of NetStreamsManager.


## Further reading

 * ASDoc

## Copyright and license

© 2011 The Away3D Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.