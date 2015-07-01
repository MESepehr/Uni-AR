/* 
 * PROJECT: FLARToolKit
 * --------------------------------------------------------------------------------
 * This work is based on the NyARToolKit developed by
 *   R.Iizuka (nyatla)
 * http://nyatla.jp/nyatoolkit/
 *
 * The FLARToolKit is ActionScript 3.0 version ARToolkit class library.
 * Copyright (C)2008 Saqoosha
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this framework; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * For further information please contact.
 *	http://www.libspark.org/wiki/saqoosha/FLARToolKit
 *	<saq(at)saqoosha.net>
 * 
 */

package com.squidder.flar.detector {
	import flash.events.EventDispatcher;		import org.libspark.flartoolkit.FLARException;	import org.libspark.flartoolkit.core.FLARSquare;	import org.libspark.flartoolkit.core.FLARSquareDetector;	import org.libspark.flartoolkit.core.FLARSquareStack;	import org.libspark.flartoolkit.core.IFLARSquareDetector;	import org.libspark.flartoolkit.core.match.FLARMatchPatt_Color_WITHOUT_PCA;	import org.libspark.flartoolkit.core.param.FLARParam;	import org.libspark.flartoolkit.core.pickup.FLARDynamicRatioColorPatt_O3;	import org.libspark.flartoolkit.core.pickup.IFLARColorPatt;	import org.libspark.flartoolkit.core.raster.FLARRaster_BitmapData;	import org.libspark.flartoolkit.core.raster.IFLARRaster;	import org.libspark.flartoolkit.core.raster.rgb.IFLARRgbRaster;	import org.libspark.flartoolkit.core.rasterfilter.rgb2bin.FLARRasterFilter_BitmapDataThreshold;	import org.libspark.flartoolkit.core.transmat.FLARTransMat;	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;	import org.libspark.flartoolkit.core.transmat.IFLARTransMat;	import org.libspark.flartoolkit.core.types.FLARIntSize;	import org.libspark.flartoolkit.detector.FLARMultiMarkerDetectorResult;		import com.squidder.flar.events.FLARDetectorEvent;		
	/**
	 * 複数のマーカーを検出し、それぞれに最も一致するARコードを、コンストラクタで登録したARコードから 探すクラスです。
	 * 最大300個を認識しますが、ゴミラベルを認識したりするので100個程度が限界です。
	 * 
	 */
	public class FLARSquidderMarkerDetector extends EventDispatcher {

		protected var _transmat:IFLARTransMat;

		private static const AR_SQUARE_MAX:int = 300;
		private var _sizeCheckEnabled:Boolean = true;
		private var _is_continue:Boolean = false;
		private var _match_patt:FLARMatchPatt_Color_WITHOUT_PCA;
		private var _square_detect:IFLARSquareDetector;
		private const _square_list:FLARSquareStack = new FLARSquareStack(AR_SQUARE_MAX);
		private var _codes:Array; // FLARCode[]
		private var _marker_width:Array; // double[]
		private var _number_of_code:int;
		private var _patt:IFLARColorPatt;
		private var _resultsArray : Array;

		/**
		 * 複数のマーカーを検出し、最も一致するARCodeをi_codeから検索するオブジェクトを作ります。
		 * 
		 * @param i_param
		 * カメラパラメータを指定します。
		 * @param i_code	FLARCode[] 
		 * 検出するマーカーのARCode配列を指定します。配列要素のインデックス番号が、そのままgetARCodeIndex関数で 得られるARCodeインデックスになります。 例えば、要素[1]のARCodeに一致したマーカーである場合は、getARCodeIndexは1を返します。
		 * 先頭からi_number_of_code個の要素には、有効な値を指定する必要があります。
		 * @param i_marker_width	double[] 
		 * i_codeのマーカーサイズをミリメートルで指定した配列を指定します。 先頭からi_number_of_code個の要素には、有効な値を指定する必要があります。
		 * @param i_number_of_code
		 * i_codeに含まれる、ARCodeの数を指定します。
		 * @throws FLARException
		 */
		public function FLARSquidderMarkerDetector(i_param:FLARParam, i_code:Array, i_marker_width:Array, i_number_of_code:int) {
			
			_resultsArray = new Array();
			
			const scr_size:FLARIntSize = i_param.getScreenSize();
			// 解析オブジェクトを作る
			this._square_detect = new FLARSquareDetector(i_param.getDistortionFactor(), scr_size);
			this._transmat = new FLARTransMat(i_param);
			// 比較コードを保存
			this._codes = i_code;
			// 比較コードの解像度は全部同じかな？（違うとパターンを複数種つくらないといけないから）
			const cw:int = i_code[0].getWidth();
			const ch:int = i_code[0].getHeight();
			for (var i:int = 1; i < i_number_of_code; i++) {
				if (cw != i_code[i].getWidth() || ch != i_code[i].getHeight()) {
					// 違う解像度のが混ざっている。
					throw new FLARException();
				}
			}

			var borderWidth:Number = (100 - i_code[0].markerPercentWidth) / 20;
			//マーカの枠高を算出
			var borderHeight:Number = (100 - i_code[0].markerPercentHeight) / 20;
			this._patt = new FLARDynamicRatioColorPatt_O3(i_code[0].getWidth(), i_code[0].getHeight(), borderWidth, borderHeight);

			// 評価パターンのホルダを作る
			//this._patt = new FLARColorPatt_O3(cw, ch);
			this._number_of_code = i_number_of_code;

			this._marker_width = i_marker_width;
			// 評価器を作る。
			this._match_patt = new FLARMatchPatt_Color_WITHOUT_PCA();
			//２値画像バッファを作る
//			this._bin_raster = new FLARBinRaster(scr_size.w, scr_size.h);
			this._bin_raster = new FLARRaster_BitmapData(scr_size.w, scr_size.h);
		}

		private var _bin_raster:IFLARRaster;

//		private var _tobin_filter:FLARRasterFilter_ARToolkitThreshold = new FLARRasterFilter_ARToolkitThreshold(100);
		private var _tobin_filter:FLARRasterFilter_BitmapDataThreshold = new FLARRasterFilter_BitmapDataThreshold(100);


		

		public function updateMarkerPosition(i_raster:IFLARRgbRaster, i_threshold:int,minimumConfidence:Number):Array {
			
			_tobin_filter.setThreshold(i_threshold);
			_tobin_filter.doFilter(i_raster, this._bin_raster);

			var l_square_list:FLARSquareStack = this._square_list;
			_square_detect.detectMarker(this._bin_raster, l_square_list);

			var unmergedResults : Array = new Array();
			var number_of_squares:int = l_square_list.getLength();
			if (number_of_squares < 1) {
				mergeResults( unmergedResults );			
				return _resultsArray;
			}

			var square:FLARSquare;
			var confidence:Number = -1;
			//_resultsArray = new Array();
			for (var i:int = 0; i < number_of_squares; i++) {

				square = l_square_list.getItem( i ) as FLARSquare;

				if (!_patt.pickFromRaster(i_raster, square)) {
					continue;
				}
				
				if (!_match_patt.setPatt(_patt)) {
					throw new FLARException();
				}
				

				for ( var code_index : int = 0; code_index < _number_of_code; code_index++) {
					
					_match_patt.evaluate( _codes[ code_index ] );
					var currentConfidence:Number = _match_patt.getConfidence();
					
					if (confidence > currentConfidence || currentConfidence < minimumConfidence ) {
						
						continue;
					}
					var result : FLARMultiMarkerDetectorResult = new FLARMultiMarkerDetectorResult( code_index , _match_patt.getDirection() , currentConfidence , square );
					if ( unmergedResults[ code_index ] == null ) unmergedResults[ code_index ] = new Array();
					unmergedResults[ code_index ].push( result );
				}
				
			}
			mergeResults( unmergedResults );			
			return _resultsArray;
		}	
		
		public function mergeResults( newResults : Array ) : void {
			
			var ev : FLARDetectorEvent;
			var newSubArray : Array;
			var resultsSubArray : Array;
			var j:*;
			
			for ( var i : int = 0 ; i < _number_of_code ; i ++ ) {
				
				if ( newResults[ i ] == null && _resultsArray[ i ] == null ) {
					
					continue;
				
				} else if ( ( newResults[ i ] == null && _resultsArray[ i ] != null ) ) {

					resultsSubArray = _resultsArray[ i ];
					for ( j in resultsSubArray ) {
		
						ev = new FLARDetectorEvent( FLARDetectorEvent.MARKER_REMOVED );
						ev.codeId = i;
						ev.codeIndex = j;
						
						trace( "SYMBOL REMOVED", ev.codeId , ev.codeIndex );	
						dispatchEvent( ev );
					}

				} else if ( ( newResults[ i ] != null && _resultsArray[ i ] == null ) ) {

					ev = new FLARDetectorEvent( FLARDetectorEvent.MARKER_ADDED );
					ev.codeId = i;
					ev.codeIndex = 0;
					
					trace( "SYMBOL ADDED" , ev.codeId );
					dispatchEvent( ev );
					
				} else if ( newResults[ i ].length > _resultsArray[ i ].length ) {

					newSubArray = newResults[ i ];
					resultsSubArray = _resultsArray[ i ];
					for ( j in newSubArray ) {

						if ( resultsSubArray[ j ] == null ) {
							
							ev = new FLARDetectorEvent( FLARDetectorEvent.MARKER_ADDED );
							ev.codeId = i;
							ev.codeIndex = j;
							
							trace( "SYMBOL ADDED", ev.codeId,ev.codeIndex );
							
							dispatchEvent( ev );					
							continue;
						}			
						
						
					}
					
					
				
				} else if ( newResults[ i ].length < _resultsArray[ i ].length ) {

					newSubArray = newResults[ i ];
					resultsSubArray = _resultsArray[ i ];
					for ( j in resultsSubArray ) {

						if ( newSubArray[ j ] == null ) {
							
							ev = new FLARDetectorEvent( FLARDetectorEvent.MARKER_REMOVED );
							ev.codeId = i;
							ev.codeIndex = j;
							
							trace( "SYMBOL REMOVED", ev.codeId,ev.codeIndex );
							
							dispatchEvent( ev );					
							continue;
						}			
					}
				}
				
				
			}
			
			_resultsArray = newResults;			
			
				
		}

		/**
		 * i_indexのマーカーに対する変換行列を計算し、結果値をo_resultへ格納します。 直前に実行したdetectMarkerLiteが成功していないと使えません。
		 * 
		 * @param i_index
		 * マーカーのインデックス番号を指定します。 直前に実行したdetectMarkerLiteの戻り値未満かつ0以上である必要があります。
		 * @param o_result
		 * 結果値を受け取るオブジェクトを指定してください。
		 * @throws FLARException
		 */
		public function getTransmationMatrix( result : FLARMultiMarkerDetectorResult , o_result:FLARTransMatResult):void {
			//const result:FLARMultiMarkerDetectorResult = this._result_holder.result_array[i_index];
			// 一番一致したマーカーの位置とかその辺を計算
			if (_is_continue) {
				_transmat.transMatContinue(result.square, result.direction, _marker_width[result.codeId], o_result);
			} else {
				_transmat.transMat(result.square, result.direction, _marker_width[result.codeId], o_result);
			}
			return;
		}
		
		public function getTransmationMatrixForResult( index:int , id : int ) : void {
			
			
		}

		public function getResult(i_index:int):FLARMultiMarkerDetectorResult
		{
			return _resultsArray[ i_index] ;
		}
		/**
		 * i_indexのマーカーの一致度を返します。
		 * 
		 * @param i_index
		 * マーカーのインデックス番号を指定します。 直前に実行したdetectMarkerLiteの戻り値未満かつ0以上である必要があります。
		 * @return マーカーの一致度を返します。0～1までの値をとります。 一致度が低い場合には、誤認識の可能性が高くなります。
		 * @throws FLARException
		 */
		public function getConfidence(i_index:int):Number {
			return getResult( i_index ).confidence;
		}

		/**
		 * i_indexのマーカーの方位を返します。
		 * 
		 * @param i_index
		 * マーカーのインデックス番号を指定します。 直前に実行したdetectMarkerLiteの戻り値未満かつ0以上である必要があります。
		 * @return 0,1,2,3の何れかを返します。
		 */
		public function getDirection(i_index:int):int {
			return getResult( i_index ).direction;
		}

		/**
		 * i_indexのマーカーのARCodeインデックスを返します。
		 * 
		 * @param i_index
		 * マーカーのインデックス番号を指定します。 直前に実行したdetectMarkerLiteの戻り値未満かつ0以上である必要があります。
		 * @return
		 */
		public function getARCodeIndex(i_index:int):int {
			return 0;
			//return this._result_holder.result_array[i_index].arcode_id;
		}

		/**
		 * getTransmationMatrixの計算モードを設定します。
		 * 
		 * @param i_is_continue
		 * TRUEなら、transMatContinueを使用します。 FALSEなら、transMatを使用します。
		 */
		public function setContinueMode(i_is_continue:Boolean):void {
			this._is_continue = i_is_continue;
		}
		
		/**
		 * 入力画像のサイズチェックをする／しない的な。（デフォルトではチェックする）
		 */
		public function get sizeCheckEnabled():Boolean {
			return this._sizeCheckEnabled;
		}
		public function set sizeCheckEnabled(value:Boolean):void {
			this._sizeCheckEnabled = value;
		}

	}
}


