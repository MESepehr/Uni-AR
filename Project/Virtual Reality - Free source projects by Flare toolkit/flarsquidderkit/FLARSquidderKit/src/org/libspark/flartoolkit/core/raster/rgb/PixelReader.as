/*  * PROJECT: FLARToolKit * -------------------------------------------------------------------------------- * This work is based on the NyARToolKit developed by *   R.Iizuka (nyatla) * http://nyatla.jp/nyatoolkit/ * * The FLARToolKit is ActionScript 3.0 version ARToolkit class library. * Copyright (C)2008 Saqoosha * * This program is free software; you can redistribute it and/or * modify it under the terms of the GNU General Public License * as published by the Free Software Foundation; either version 2 * of the License, or (at your option) any later version. *  * This program is distributed in the hope that it will be useful, * but WITHOUT ANY WARRANTY; without even the implied warranty of * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the * GNU General Public License for more details. *  * You should have received a copy of the GNU General Public License * along with this framework; if not, write to the Free Software * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA *  * For further information please contact. *	http://www.libspark.org/wiki/saqoosha/FLARToolKit *	<saq(at)saqoosha.net> *  */package org.libspark.flartoolkit.core.raster.rgb {	import org.libspark.flartoolkit.core.rasterreader.IFLARRgbPixelReader;			/**	 * @author Saqoosha	 */	public class PixelReader implements IFLARRgbPixelReader {			private var _parent:FLARRgbRaster_BGRA;			public function PixelReader(i_parent:FLARRgbRaster_BGRA) {			this._parent = i_parent;		}			/**		 * @param o_rgb	int[]		 */		public function getPixel(i_x:int, i_y:int, o_rgb:Array):void {			var ref_buf:Array = this._parent.refBuf;// byte[]			var bp:int = (i_x + i_y * this._parent.getWidth()) * 4;			o_rgb[0] = (ref_buf[bp + 2] & 0xff);// R			o_rgb[1] = (ref_buf[bp + 1] & 0xff);// G			o_rgb[2] = (ref_buf[bp + 0] & 0xff);// B			return;		}			/**		 * @param i_x	int[]		 * @param i_y	int[]		 * @param i_num	int		 * @param o_rgb	int[]		 */		public function getPixelSet(i_x:Array, i_y:Array, i_num:int, o_rgb:Array):void {			var width:int = _parent.getWidth();			var ref_buf:Array = _parent.refBuf;			//			var bp:int;			for (var i:int = i_num - 1; i >= 0; i--) {				bp = (i_x[i] + i_y[i] * width) * 4;				o_rgb[i * 3 + 0] = (ref_buf[bp + 2] & 0xff);// R				o_rgb[i * 3 + 1] = (ref_buf[bp + 1] & 0xff);// G				o_rgb[i * 3 + 2] = (ref_buf[bp + 0] & 0xff);// B			}		}	}}