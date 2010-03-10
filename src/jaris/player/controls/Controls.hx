﻿/**    
 * @author Jefferson González
 * @copyright 2010 Jefferson González
 *
 * @license 
 * This file is part of Jaris FLV Player.
 *
 * Jaris FLV Player is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License or GNU LESSER GENERAL 
 * PUBLIC LICENSE as published by the Free Software Foundation, either version 
 * 3 of the License, or (at your option) any later version.
 *
 * Jaris FLV Player is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License and 
 * GNU LESSER GENERAL PUBLIC LICENSE along with Jaris FLV Player.  If not, 
 * see <http://www.gnu.org/licenses/>.
 */

package jaris.player.controls;

//{Libraries
import flash.display.GradientType;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.Lib;
import flash.events.MouseEvent;
import flash.display.MovieClip;
import flash.net.NetStream;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;
import jaris.animation.Animation;
import jaris.display.Loader;
import jaris.events.PlayerEvents;
import jaris.player.controls.AspectRatioIcon;
import jaris.player.controls.FullscreenIcon;
import jaris.player.controls.PauseIcon;
import jaris.player.controls.PlayIcon;
import jaris.player.controls.VolumeIcon;
import jaris.player.Player;
import flash.display.Sprite;
import flash.display.Stage;
import jaris.utils.Utils;
//}

/**
 * Default controls for jaris player
 */
class Controls extends MovieClip {
	
	//{Member Variables
	private var _thumb:Sprite;
	private var _track:Sprite;
	private var _trackDownloaded:Sprite;
	private var _trackBar:Sprite;
	private var _scrubbing:Bool;
	private var _stage:Stage;
	private var _movieClip:MovieClip;
	private var _player:Player;
	private var _darkColor:UInt;
	private var _brightColor:UInt;
	private var _controlColor:UInt;
	private var _hoverColor:UInt;
	private var _hideControlsTimer:Timer;
	private var _currentPlayTimeLabel:TextField;
	private var _totalPlayTimeLabel:TextField;
	private var _seekPlayTimeLabel:TextField;
	private var _percentLoaded:Float;
	private var _controlsVisible:Bool;
	private var _seekBar:Sprite;
	private var _controlsBar:Sprite;
	private var _playControl:PlayIcon;
	private var _pauseControl:PauseIcon;
	private var _aspectRatioControl:AspectRatioIcon;
	private var _fullscreenControl:FullscreenIcon;
	private var _volumeIcon:VolumeIcon;
	private var _volumeTrack:Sprite;
	private var _volumeSlider:Sprite;
	private var _loader:Loader;
	//}
	
	
	//{Constructor
	public function new(player:Player)
	{
		super();
		
		//{Main variables
		_stage = Lib.current.stage;
		_movieClip = Lib.current;
		_player = player;
		_darkColor = 0x000000;
		_brightColor = 0x4c4c4c;
		_controlColor = 0xFFFFFF;
		_hoverColor = 0x67A8C1;
		_percentLoaded = 0.0;
		_hideControlsTimer = new Timer(500);
		_controlsVisible = false;
		//}
		
		//{Seeking Controls initialization
		_seekBar = new Sprite();
		addChild(_seekBar);
		
		_trackBar = new Sprite(  );
		_trackBar.tabEnabled = false;
		_seekBar.addChild(_trackBar);
		
		_trackDownloaded = new Sprite(  );
		_trackDownloaded.tabEnabled = false;
		_seekBar.addChild(_trackDownloaded);
		
		_track = new Sprite(  );
		_track.tabEnabled = false;
		_track.buttonMode = true;
		_track.useHandCursor = true;
		_seekBar.addChild(_track);
		
		
		_thumb = new Sprite(  );
		_thumb.buttonMode = true;
		_thumb.useHandCursor = true;
		_thumb.tabEnabled = false;
		_seekBar.addChild(_thumb);
		
		_currentPlayTimeLabel = new TextField();
		_currentPlayTimeLabel.autoSize = TextFieldAutoSize.LEFT;
		_currentPlayTimeLabel.text = "00:00:00";
		_currentPlayTimeLabel.tabEnabled = false;
		_seekBar.addChild(_currentPlayTimeLabel);
		
		_totalPlayTimeLabel = new TextField();
		_totalPlayTimeLabel.autoSize = TextFieldAutoSize.LEFT;
		_totalPlayTimeLabel.text = "00:00:00";
		_totalPlayTimeLabel.tabEnabled = false;
		_seekBar.addChild(_totalPlayTimeLabel);
		
		_seekPlayTimeLabel = new TextField();
		_seekPlayTimeLabel.visible = false;
		_seekPlayTimeLabel.autoSize = TextFieldAutoSize.LEFT;
		_seekPlayTimeLabel.text = "00:00:00";
		_seekPlayTimeLabel.tabEnabled = false;
		addChild(_seekPlayTimeLabel);
		
		drawSeekControls();
		//}
		
		//{Playing controls initialization
		_controlsBar = new Sprite();
		_controlsBar.visible = true;
		addChild(_controlsBar);
		
		_playControl = new PlayIcon(0, 0, 0, 0, _controlColor, _hoverColor);
		_controlsBar.addChild(_playControl);
		
		_pauseControl = new PauseIcon(0, 0, 0, 0, _controlColor, _hoverColor);
		_pauseControl.visible = false;
		_controlsBar.addChild(_pauseControl);
		
		_aspectRatioControl = new AspectRatioIcon(0, 0, 0, 0, _controlColor, _hoverColor);
		_controlsBar.addChild(_aspectRatioControl);
		
		_fullscreenControl = new FullscreenIcon(0, 0, 0, 0, _controlColor, _hoverColor);
		_controlsBar.addChild(_fullscreenControl);
		
		_volumeIcon = new VolumeIcon(0, 0, 0, 0, _controlColor, _hoverColor);
		_controlsBar.addChild(_volumeIcon);
		
		_volumeSlider = new Sprite();
		_controlsBar.addChild(_volumeSlider);
		
		_volumeTrack = new Sprite();
		_volumeTrack.buttonMode = true;
		_volumeTrack.useHandCursor = true;
		_volumeTrack.tabEnabled = false;
		_controlsBar.addChild(_volumeTrack); 
		//}
		
		//{Loader bar
		_loader = new Loader();
		_loader.hide();
		
		var loaderColors:Array <String> = ["", "", "", ""];
		loaderColors[0] = Std.string(_brightColor);
		loaderColors[1] = Std.string(_controlColor);
		
		_loader.setColors(loaderColors);
		
		addChild(_loader);
		//}
		
		//{event Listeners
		_movieClip.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		_thumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
		_thumb.addEventListener(MouseEvent.MOUSE_UP, onThumbMouseUp);
		_thumb.addEventListener(MouseEvent.MOUSE_OVER, onThumbHover);
		_thumb.addEventListener(MouseEvent.MOUSE_OUT, onThumbMouseOut);
		_thumb.addEventListener(MouseEvent.MOUSE_MOVE, onTrackMouseMove);
		_thumb.addEventListener(MouseEvent.MOUSE_OUT, onTrackMouseOut);
		_track.addEventListener(MouseEvent.CLICK, onTrackClick);
		_track.addEventListener(MouseEvent.MOUSE_MOVE, onTrackMouseMove);
		_track.addEventListener(MouseEvent.MOUSE_OUT, onTrackMouseOut);
		_trackBar.addEventListener(MouseEvent.MOUSE_OUT, onThumbMouseUp);
		_playControl.addEventListener(MouseEvent.CLICK, onPlayClick);
		_pauseControl.addEventListener(MouseEvent.CLICK, onPauseClick);
		_aspectRatioControl.addEventListener(MouseEvent.CLICK, onAspectRatioClick);
		_fullscreenControl.addEventListener(MouseEvent.CLICK, onFullscreenClick);
		_volumeIcon.addEventListener(MouseEvent.CLICK, onVolumeIconClick);
		_volumeTrack.addEventListener(MouseEvent.CLICK, onVolumeTrackClick);
		
		_player.addEventListener(PlayerEvents.FULLSCREEN, onPlayerFullScreen);
		_player.addEventListener(PlayerEvents.MOUSE_HIDE, onPlayerMouseHide);
		_player.addEventListener(PlayerEvents.MOUSE_SHOW, onPlayerMouseShow);
		_player.addEventListener(PlayerEvents.MEDIA_INITIALIZED, onPlayerMediaInitialized);
		_player.addEventListener(PlayerEvents.BUFFERING, onPlayerBuffering);
		_player.addEventListener(PlayerEvents.NOT_BUFFERING, onPlayerNotBuffering);
		_player.addEventListener(PlayerEvents.RESIZE, onPlayerResize);
		_player.addEventListener(PlayerEvents.PLAY_PAUSE, onPlayerPlayPause);
		_player.addEventListener(PlayerEvents.PLAYBACK_FINISHED, onPlayerPlaybackFinished);
		_player.addEventListener(PlayerEvents.CONNECTION_FAILED, onPlayerStreamNotFound);
		
		_stage.addEventListener(MouseEvent.MOUSE_UP, onThumbMouseUp);
		_stage.addEventListener(MouseEvent.MOUSE_OUT, onThumbMouseUp);
		_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		
		_hideControlsTimer.addEventListener(TimerEvent.TIMER, hideControlsTimer);
		
		_hideControlsTimer.start();
		//}
	}
	//}

	
	//{Timers
	/**
	 * Hides the playing controls when not moving mouse.
	 * @param	event The timer event associated
	 */
	private function hideControlsTimer(event:TimerEvent):Void
	{
		if (_player.isPlaying())
		{
			if (_controlsVisible)
			{
				if (_stage.mouseX < _controlsBar.x || 
					_stage.mouseX >= _stage.stageWidth - 1 || 
					_stage.mouseY >= _stage.stageHeight - 1 ||
					_stage.mouseY <= 1
				   )
				{
					_controlsVisible = false;
				}
			}
			else
			{
				hideControls();
				_hideControlsTimer.stop();
			}
		}
	}
	//}
	
	
	//{Events
	/**
	 * Keeps syncronized various elements of the controls like the thumb and download track bar
	 * @param	event
	 */
	private function onEnterFrame(event:Event)
	{
		if(_player.getDuration() > 0) {
			if(_scrubbing) {
				_player.seek(_player.getDuration() * (_thumb.x / _track.width));
			}
			else {
				_currentPlayTimeLabel.text = Utils.formatTime(_player.getTime());
				_thumb.x = (_player.getTime()+_player.getStartTime()) / _player.getDuration() * (_track.width-_thumb.width);
			}
		}
		
		_volumeSlider.height = _volumeTrack.height * (_player.getVolume() / 1.0);
		_volumeSlider.y = (_volumeTrack.y + _volumeTrack.height) - _volumeSlider.height;
		
		drawDownloadProgress();
	}
	
	/**
	 * Show playing controls on mouse movement.
	 * @param	event
	 */
	private function onMouseMove(event:MouseEvent):Void
	{
		if (_stage.mouseX >= _controlsBar.x)
		{
			if (!_hideControlsTimer.running)
			{
				_hideControlsTimer.start();
			}
			
			_controlsVisible = true;
			showControls();
		}
	}
	
	/**
	 * Toggles pause or play
	 * @param	event
	 */
	private function onPlayClick(event:MouseEvent):Void
	{
		_player.togglePlay();
		_playControl.visible = !_player.isPlaying();
		_pauseControl.visible = _player.isPlaying();
	}
	
	/**
	 * Toggles pause or play
	 * @param	event
	 */
	private function onPauseClick(event:MouseEvent):Void
	{
		_player.togglePlay();
		_playControl.visible = !_player.isPlaying();
		_pauseControl.visible = _player.isPlaying();
	}
	
	/**
	 * Toggles betewen aspect ratios
	 * @param	event
	 */
	private function onAspectRatioClick(event:MouseEvent):Void
	{
		_player.toggleAspectRatio();
	}
	
	/**
	 * Toggles between window and fullscreen mode
	 * @param	event
	 */
	private function onFullscreenClick(event:MouseEvent)
	{
		_player.toggleFullscreen();
	}
	
	/**
	 * Toggles between mute and unmute
	 * @param	event
	 */
	private function onVolumeIconClick(event: MouseEvent)
	{
		_player.toggleMute();
	}
	
	/**
	 * Detect user click on volume track control and change volume according
	 * @param	event
	 */
	private function onVolumeTrackClick(event:MouseEvent)
	{
		var percent:Float = _volumeTrack.height - _volumeTrack.mouseY;
		var volume:Float = 1.0 * (percent / _volumeTrack.height);
		
		_player.setVolume(volume);
	}
	
	/**
	 * Display not found message
	 * @param	event
	 */
	private function onPlayerStreamNotFound(event:PlayerEvents):Void
	{
		//todo: to work on this
	}	
	
	/**
	 * Shows the loader bar when buffering
	 * @param	event
	 */
	private function onPlayerBuffering(event:PlayerEvents):Void
	{
		_loader.show();
	}
	
	/**
	 * Hides loader bar when not buffering
	 * @param	event
	 */
	private function onPlayerNotBuffering(event:PlayerEvents):Void
	{
		_loader.hide();
	}
		
	/**
	 * Monitors playbeack when finishes tu update controls
	 * @param	event
	 */
	private function onPlayerPlaybackFinished(event:PlayerEvents):Void
	{
		_playControl.visible = !_player.isPlaying();
		_pauseControl.visible = _player.isPlaying();
		showControls();
	}
	
	/**
	 * Monitors keyboard play pause actions to update icons
	 * @param	event
	 */
	private function onPlayerPlayPause(event:PlayerEvents)
	{
		_playControl.visible = !_player.isPlaying();
		_pauseControl.visible = _player.isPlaying();
	}
	
	/**
	 * Function fired by the player FULLSCREEN event that redraws the player controls
	 * @param	event
	 */
	private function onPlayerFullScreen(event:PlayerEvents)
	{
		redrawControls();
	}
	
	/**
	 * Resizes the video player on windowed mode substracting the seekbar height
	 * @param	event
	 */
	private function onPlayerResize(event:PlayerEvents)
	{
		if (!_player.isFullscreen())
		{
			_player.getVideo().height = _stage.stageHeight - _trackBar.height;
			_player.getVideo().width = _player.getVideo().height * _player.getAspectRatio();
			
			_player.getVideo().x = (_stage.stageWidth / 2) - (_player.getVideo().width / 2);
		}
		
		redrawControls();
	}
	
	/**
	 * Updates media total time duration.
	 * @param	event
	 */
	private function onPlayerMediaInitialized(event:PlayerEvents):Void
	{
		_totalPlayTimeLabel.text = Utils.formatTime(event.duration);
		_playControl.visible = !_player.isPlaying();
		_pauseControl.visible = _player.isPlaying();
	}
	
	/**
	 * Hides seekbar if on fullscreen.
	 * @param	event
	 */
	private function onPlayerMouseHide(event:PlayerEvents)
	{
		if (_seekBar.visible && _player.isFullscreen())
		{
			Animation.slideOut(_seekBar, "bottom", 1000);
		}
	}
	
	/**
	 * Shows seekbar
	 * @param	event
	 */
	private function onPlayerMouseShow(event:PlayerEvents)
	{
		//Only use slidein effect on fullscreen since switching to windowed mode on
		//hardware scaling causes a bug by a slow response on stage height changes
		if (_player.isFullscreen() && !_seekBar.visible)
		{
			Animation.slideIn(_seekBar, "bottom",1000);
		}
		else
		{
			_seekBar.visible = true;
		}
	}
	
	/**
	 * Translates a user click in to time and seeks to it
	 * @param	event
	 */
	private function onTrackClick(event:MouseEvent)
	{
		var clickPosition:Float = _track.mouseX - _currentPlayTimeLabel.width;
		_player.seek(_player.getDuration() * (clickPosition / _track.width));
	}
	
	/**
	 * Shows a small tooltip showing the time calculated by mouse position
	 * @param	event
	 */
	private function onTrackMouseMove(event:MouseEvent):Void
	{
		var clickPosition:Float = _track.mouseX - _currentPlayTimeLabel.width;
		_seekPlayTimeLabel.text = Utils.formatTime(_player.getDuration() * (clickPosition / _track.width));
		
		_seekPlayTimeLabel.y = _stage.stageHeight - _trackBar.height - _seekPlayTimeLabel.height - 1;
		_seekPlayTimeLabel.x = clickPosition + (_seekPlayTimeLabel.width / 2);
		
		_seekPlayTimeLabel.backgroundColor = _brightColor;
		_seekPlayTimeLabel.background = true;
		_seekPlayTimeLabel.textColor = _controlColor;
		_seekPlayTimeLabel.borderColor = _darkColor;
		_seekPlayTimeLabel.border = true;
		
		if (!_seekPlayTimeLabel.visible)
		{
			Animation.fadeIn(_seekPlayTimeLabel, 300);
		}
	}
	
	/**
	 * Hides the tooltip that shows the time calculated by mouse position
	 * @param	event
	 */
	private function onTrackMouseOut(event:MouseEvent):Void
	{
		Animation.fadeOut(_seekPlayTimeLabel, 300);
	}
	
	/**
	 * Enables dragging of thumb for seeking media
	 * @param	event
	 */
	private function onThumbMouseDown(event:MouseEvent)
	{
		_scrubbing = true;
		var rectangle:Rectangle = new Rectangle(_track.x, _track.y, _track.width-_thumb.width, 0);
		_thumb.startDrag(false, rectangle);
	}
	
	/**
	 * Changes thumb seek control to hover color
	 * @param	event
	 */
	private function onThumbHover(event:MouseEvent)
	{
		_thumb.graphics.lineStyle();
		_thumb.graphics.beginFill(_hoverColor);
		_thumb.graphics.drawRect(_currentPlayTimeLabel.width, (_seekBar.height/2)-(10/2), 10, 10);
		_thumb.graphics.endFill();
	}
	
	/**
	 * Changes thumb seek control to control color
	 * @param	event
	 */
	private function onThumbMouseOut(event:MouseEvent)
	{
		_thumb.graphics.lineStyle();
		_thumb.graphics.beginFill(_controlColor);
		_thumb.graphics.drawRect(_currentPlayTimeLabel.width, (_seekBar.height/2)-(10/2), 10, 10);
		_thumb.graphics.endFill();
	}
	
	/**
	 * Disables dragging of thumb
	 * @param	event
	 */
	private function onThumbMouseUp(event:MouseEvent) 
	{
		_scrubbing = false;
		_thumb.stopDrag(  );
	}
	//}
	
	
	//{Drawing functions
	/**
	 * Clears all current graphics a draw new ones
	 */
	private function redrawControls():Void
	{	
		var count:UInt = 1;
		//draw until seekbar width == stage width
		if(_seekBar.width != _stage.stageWidth && count <= 3)
		{
			drawSeekControls();
			
			count++;
		}
		
		drawPlayingControls();
	}
	
	/**
	 * Draws the download progress track bar
	 */
	private function drawDownloadProgress():Void
	{
		if (_player.getBytesTotal() > 0)
		{
			var bytesLoaded:Float = _player.getBytesLoaded();
			var bytesTotal:Float = _player.getBytesTotal();
			
			_percentLoaded = bytesLoaded / bytesTotal;
		}
		
		var position:Float = _player.getStartTime() / _player.getDuration();
		
		_trackDownloaded.graphics.clear();
		
		_trackDownloaded.graphics.lineStyle();
		_trackDownloaded.graphics.beginFill(_brightColor, 0xFFFFFF);
		_trackDownloaded.graphics.drawRect(_currentPlayTimeLabel.width + (position * _track.width), (_seekBar.height / 2) - (10 / 2), _track.width * _percentLoaded, 10);
		_trackDownloaded.graphics.endFill();
	}
	
	/**
	 * Draws all seekbar controls
	 */
	private function drawSeekControls()
	{
		//Reset sprites for redraw
		_seekBar.graphics.clear();
		_trackBar.graphics.clear();
		_track.graphics.clear();
		_thumb.graphics.clear();
		
		_seekBar.x = 0;
		_seekBar.y = _stage.stageHeight - 25;
		_seekBar.graphics.lineStyle();
		_seekBar.graphics.beginFill(0x000000, 0);
		_seekBar.graphics.drawRect(0, 0, _stage.stageWidth, 25);
		_seekBar.graphics.endFill();
		_seekBar.width = _stage.stageWidth;	
		_seekBar.height = 25;
		
		var matrix:Matrix = new Matrix(  );
		matrix.createGradientBox(_seekBar.width, 25, Utils.degreesToRadians(90), 0, _seekBar.height-25);
		var colors:Array<UInt> = [_brightColor, _darkColor];
		var alphas:Array<UInt> = [1, 1];
		var ratios:Array<UInt> = [0, 255];
		_trackBar.graphics.lineStyle();
		_trackBar.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
		_trackBar.graphics.drawRect(0, 0, _seekBar.width, _seekBar.height);
		_trackBar.graphics.endFill(  );
		
		_currentPlayTimeLabel.textColor = _controlColor;
		_currentPlayTimeLabel.y = _seekBar.height - (_trackBar.height/2)-(_currentPlayTimeLabel.height/2);
		
		_totalPlayTimeLabel.textColor = _controlColor;
		_totalPlayTimeLabel.x = _seekBar.width - _totalPlayTimeLabel.width;
		_totalPlayTimeLabel.y = _seekBar.height - (_trackBar.height / 2) - (_totalPlayTimeLabel.height / 2);
		
		drawDownloadProgress();
		
		_track.graphics.lineStyle(1, _controlColor);
		_track.graphics.beginFill(_darkColor, 0);
		_track.graphics.drawRect(_currentPlayTimeLabel.width, (_seekBar.height / 2) - (10 / 2), _seekBar.width - _currentPlayTimeLabel.width - _totalPlayTimeLabel.width, 10);
		_track.graphics.endFill();
		
		_thumb.graphics.lineStyle();
		_thumb.graphics.beginFill(_controlColor);
		_thumb.graphics.drawRect(_currentPlayTimeLabel.width, (_seekBar.height/2)-(10/2), 10, 10);
		_thumb.graphics.endFill();
	}
	
	/**
	 * Draws control bar player controls
	 */
	private function drawPlayingControls():Void
	{
		//Reset sprites for redraw
		_controlsBar.graphics.clear();
		_volumeTrack.graphics.clear();
		_volumeSlider.graphics.clear();
		
		//Draw controls bar
		var barWidth = _stage.stageHeight < 330 ? 45 : 60;
		var barMargin = _stage.stageHeight < 330 ? 5 : 25;
		_controlsBar.x = (_stage.stageWidth - barWidth) + 20;
		_controlsBar.y = barMargin;
		
		var matrix:Matrix = new Matrix(  );
		matrix.createGradientBox(barWidth, _stage.stageHeight - 75, Utils.degreesToRadians(0), 0, _stage.stageHeight-75);
		var colors:Array<UInt> = [_brightColor, _darkColor];
		var alphas:Array<Float> = [0.75, 0.75];
		var ratios:Array<UInt> = [0, 255];
		_controlsBar.graphics.lineStyle();
		_controlsBar.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
		_controlsBar.graphics.drawRoundRect(0, 0, barWidth, _stage.stageHeight-_seekBar.height-(barMargin * 2), 20, 20);
		_controlsBar.graphics.endFill();
		_controlsBar.width = barWidth;	
		_controlsBar.height = _stage.stageHeight - _seekBar.height - (barMargin * 2);
		
		var topMargin:Float = _stage.stageHeight < 330 ? 5 : 10;
		var barCenter:Float = (_controlsBar.width - 20) / 2;
		var buttonSize:Float = ((80 / 100) * (_controlsBar.width - 20));
		var buttonX:Float = buttonSize / 2;
		
		//Draw playbutton
		_playControl.setNormalColor(_controlColor);
		_playControl.setHoverColor(_hoverColor);
		_playControl.setPosition(barCenter - buttonX, topMargin);
		_playControl.setSize(buttonSize, buttonSize);
		
		//Draw pausebutton
		_pauseControl.setNormalColor(_controlColor);
		_pauseControl.setHoverColor(_hoverColor);
		_pauseControl.setPosition(_playControl.x, topMargin);
		_pauseControl.setSize(buttonSize, buttonSize);
		
		//Draw aspec ratio button
		_aspectRatioControl.setNormalColor(_controlColor);
		_aspectRatioControl.setHoverColor(_hoverColor);
		_aspectRatioControl.setPosition(_playControl.x, (_playControl.y + buttonSize) + topMargin);
		_aspectRatioControl.setSize(buttonSize, buttonSize);
		
		//Draw fullscreen button
		_fullscreenControl.setNormalColor(_controlColor);
		_fullscreenControl.setHoverColor(_hoverColor);
		_fullscreenControl.setPosition(_playControl.x, (_aspectRatioControl.y + _aspectRatioControl.height) + topMargin);
		_fullscreenControl.setSize(buttonSize, buttonSize);
		
		//Draw volume icon
		_volumeIcon.setNormalColor(_controlColor);
		_volumeIcon.setHoverColor(_hoverColor);
		_volumeIcon.setPosition(_playControl.x, _controlsBar.height - _playControl.height - topMargin);
		_volumeIcon.setSize(buttonSize, buttonSize);
		
		//Draw volume track
		_volumeTrack.x = _playControl.x;
		_volumeTrack.y = (_fullscreenControl.y + _fullscreenControl.height) + topMargin;
		_volumeTrack.graphics.lineStyle(1, _controlColor);
		_volumeTrack.graphics.beginFill(0x000000, 0);
		_volumeTrack.graphics.drawRect(0, 0, _playControl.width / 2, _volumeIcon.y - (_fullscreenControl.y + _fullscreenControl.height) - (topMargin*2));
		_volumeTrack.graphics.endFill();
		_volumeTrack.x = barCenter - (_volumeTrack.width / 2);
		
		//Draw volume slider
		_volumeSlider.x = _volumeTrack.x;
		_volumeSlider.y = _volumeTrack.y;
		_volumeSlider.graphics.lineStyle();
		_volumeSlider.graphics.beginFill(_controlColor, 1);
		_volumeSlider.graphics.drawRect(0, 0, _volumeTrack.width, _volumeTrack.height);
		_volumeSlider.graphics.endFill();
		
	}
	//}
	
	
	//{Private Methods
	/**
	 * Hide de play controls bar
	 */
	private function hideControls():Void
	{
		if(_controlsBar.visible)
		{
			drawPlayingControls();	
			Animation.slideOut(_controlsBar, "right", 800);
		}
	}
	
	/**
	 * Shows play controls bar
	 */
	private function showControls():Void
	{
		if(!_controlsBar.visible)
		{
			drawPlayingControls();	
			Animation.slideIn(_controlsBar, "right", 800);
		}
	}
	//}
	
	
	//{Setters
	/**
	 * Sets the player colors and redraw them
	 * @param	colors Array of colors in the following order: darkColor, brightColor, controlColor, hoverColor
	 */
	public function setControlColors(colors:Array<String>):Void
	{
		_darkColor = colors[0].length > 0? Std.parseInt("0x" + colors[0]) : 0x000000;
		_brightColor = colors[1].length > 0? Std.parseInt("0x" + colors[1]) : 0x4c4c4c;
		_controlColor = colors[2].length > 0? Std.parseInt("0x" + colors[2]) : 0xFFFFFF;
		_hoverColor = colors[3].length > 0? Std.parseInt("0x" + colors[3]) : 0x67A8C1;
		
		var loaderColors:Array <String> = ["", ""];
		loaderColors[0] = colors[1];
		loaderColors[1] = colors[2];
		_loader.setColors(loaderColors);
		
		redrawControls();
	}
	
	public function setDurationLabel(duration:String):Void
	{
		//Person passed time already formatted
		if (duration.indexOf(":") != -1)
		{
			_totalPlayTimeLabel.text = duration;
		}
		
		//Time passed in seconds
		else
		{
			_totalPlayTimeLabel.text = Std.string(Utils.formatTime(Std.parseFloat(duration)));
		}
	}
	//}
	
}