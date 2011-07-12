/*
 * @(#)SuperPanelContainer  1.0.0 2010/01/08
 *
 * Copyright (c) 2010, TOTVS S/A. Todos os direitos reservados.
 *
 * Os Programas desta Aplicação (que incluem tanto o software quanto a sua
 * documentação) contém informações proprietárias da TOTVS S/A; eles são
 * licenciados de acordo com um contrato de licença contendo restrições de uso e
 * confidencialidade, e são também protegidos pela Lei 9609/98 e 9/610/98,
 * respectivamente Lei do Software e Lei dos Direitos Autorais. Engenharia
 * reversa, descompilação e desmontagem dos programas são proibidos. Nenhuma
 * parte destes programas pode ser reproduzida ou transmitida de nenhuma forma e
 * por nenhum meio, eletrônico ou mecânico, por motivo algum, sem a permissão
 * escrita da TOTVS S/A.
 */
package com.datasul.ui.framework.container {
	
	import com.datasul.framework.ui.progressmonitor.SimpleProgressMonitor;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import flexlib.containers.FlowBox;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.containers.Canvas;
	import mx.controls.scrollClasses.ScrollBar;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	
	import nl.wv.extenders.panel.SuperPanelEmbbedImagesSource;
	import nl.wv.extenders.panel.SuperPanel;
	import nl.flexcoders.labs.repeatedbackground.RepeatedBackground;
	
	/**
	 * Container para comportar o superpanel e suas subclasses.
	 **/
	public class SuperPanelContainer extends Canvas {
		
		private var pm:SimpleProgressMonitor;
		
		private var flowBox:FlowBox;
		
		private var grid:Canvas;
		
		private var _rows:int = 2;
		
		private var _columns:int = 4;
		
		private var nextPos:int = 20;
		
		private var defaultWidth:int;
		
		private var defaultHeight:int;
		
		//Paineis a serem organizados
		private var organizeChildren:Array;
		
		private var restoring:Boolean = false;
		
		private var organizing:Boolean = false;
		
		/**
		 * Construtor da classe
		 **/
		public function SuperPanelContainer() {
			//Desliga scroll horizontal
			this.horizontalScrollPolicy = "off";
			
			//Progress monitor
			pm = new SimpleProgressMonitor();
			pm.modal = true;
			pm.label = "Organizando...";
		
			//setStyle("backgroundImage", SuperPanelEmbbedImagesSource.grid);
			//cacheAsBitmap = true;
		
		}
		
		/**
		 * Completa os cálculos de fluxo
		 */
		private function flowCalculationCompleted(e:Event):void {
			flowBox.removeEventListener(FlexEvent.UPDATE_COMPLETE, flowCalculationCompleted);
			
			flowBox.callLater(setNewPositions);
		}
		
		/**
		 * Atribui nova posição ao panel
		 */
		private function setNewPositions():void {
			for (var i:int = 0; i < organizeChildren.length; i++) {
				var child:SuperPanel = organizeChildren[i] as SuperPanel;
				var newPosition:DisplayObject = flowBox.getChildAt(i);
				
				child.
						forcePosition(newPosition.x + this.getStyle("paddingTop"),
						newPosition.y + this.getStyle("paddingLeft"), newPosition.width, newPosition.height);
			}
			
			cleanUp();
		}
		
		/**
		 * Limpa a tela
		 */
		private function cleanUp():void {
			flowBox.removeAllChildren();
			this.rawChildren.removeChild(flowBox);
			flowBox = null;
			organizeChildren = null;
			callLater(function():void {
						pm.hide();
						restoring = false;
						organizing = false;
					});
		}
		
		/**
		 * Organiza os super panel utilizando o algoritmo do flexlib.containers.FlowBox
		 */
		public function restore():void {
			//Nao organiza se nao tiver filhos
			if (numChildren == 0) {
				return;
			}
			
			nextPos = 20;
			
			if (restoring) {
				return;
			}
			restoring = true;
			pm.show();
			
			organizeChildren = this.getChildren();
			//Cria depois de pegar os filhos para evitar de pegar o proprio flow...
			createFlowBox();
			calcDefaultDimensions();
			
			//Ordena a lista de filhos
			var sort:Sort = new Sort();
			sort.compareFunction = superPanelSort;
			sort.sort(organizeChildren);
			
			for (var i:int = 0; i < organizeChildren.length; i++) {
				var child:SuperPanel = organizeChildren[i] as SuperPanel;
				child.setRestore();
				//Reseta as posições (retira buracos)
				child.oPosition = i;
			}
			
			callLater(calcNewPositions);
		}
		
		/**
		 * Organiza os super panel utilizando o algoritmo do flexlib.containers.FlowBox
		 */
		public function organize():void {
			//Nao organiza se nao tiver filhos
			if (numChildren == 0) {
				return;
			}
			
			if (organizing) {
				return;
			}
			this.organizing = true;
			restore();
		}
		
		/**
		 * Efetua os cálculos para validas as posições dos panels
		 */
		private function calcNewPositions():void {
			flowBox.addEventListener(FlexEvent.UPDATE_COMPLETE, flowCalculationCompleted, false, 0, true);
			
			for each (var child:SuperPanel in organizeChildren) {
				var uic:UIComponent = new UIComponent();
				
				//Respeita o tamanho minimo do portlet
				if (!organizing && child.minWidth > defaultWidth) {
					uic.width =
							Math.ceil(child.minWidth / defaultWidth) * defaultWidth +
							(Math.ceil(child.minWidth / defaultWidth) - 1) * 10;
					
					uic.height =
							Math.ceil(child.minHeight / defaultHeight) * defaultHeight +
							(Math.ceil(child.minHeight / defaultHeight) - 1) * 10;
				} else if (!organizing && child.minWidth <= defaultWidth) {
					uic.width = defaultWidth;
					uic.height = defaultHeight;
				} else {
					uic.width = child.width;
					uic.height = child.height;
				}
				
				flowBox.addChild(uic);
			}
		
		}
		
		/**
		 * Flow layout para calcular a posição dos itens no organizar
		 */
		private function createFlowBox():void {
			flowBox = new FlowBox();
			
			flowBox.x = 0;
			flowBox.y = 0;
			flowBox.width = width;
			flowBox.height = height;
			
			flowBox.setStyle("horizontalGap", 10);
			flowBox.setStyle("verticalGap", 10);
			
			//Adiciona diretamente no pai para evitar tratamento
			this.rawChildren.addChildAt(flowBox, 0);
		}
		
		/**
		 * Função que organiza a lista de filhos.
		 *
		 * @param a - primeiro SuperPanel a ser comparado
		 * @param b - segundo SuperPanel a ser comparado
		 *
		 * SQA: recebe três pois a função sort exige o último parâmetro
		 **/
		private function superPanelSort(a:SuperPanel, b:SuperPanel, something:*):int {
			return ObjectUtil.numericCompare(a.oPosition, b.oPosition);
		}
		
		/**
		 * Adiciona portlet filho ao Super Panel em posição específica
		 */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			if (child as SuperPanel) {
				child.x = nextPos;
				child.y = nextPos;
				nextPos = nextPos + 20;
				return super.addChildAt(child, index);
			} else {
				throw new Error("To add a child to SuperPanelContainer, the child must be an instance of SuperPanel.");
			}
		}
		
		/**
		 * Adiciona portlet filho ao Super Panel
		 */
		override public function addChild(child:DisplayObject):DisplayObject {
			if (child as SuperPanel) {
				return super.addChild(child);
			} else {
				throw new Error("To add a child to SuperPanelContainer, the child must be an instance of SuperPanel.");
			}
		}
		
		/**
		 * Atualiza a tela
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		/*
		   graphics.lineStyle(1, 0x505050, 0.5);
		   for (var i:int = 0; i < this.width; i = i + 30) {
		   graphics.moveTo(i, 0);
		   graphics.lineTo(i, height);
		   }
		   for (var j:int = 0; j < this.height; j = j + 30) {
		   graphics.moveTo(0, j);
		   graphics.lineTo(width, j);
		 }*/
		}
		
		public function get rows():int {
			return this._rows;
		}
		
		public function set rows(rows:int):void {
			this._rows = rows;
		}
		
		public function get columns():int {
			return this._columns;
		}
		
		public function set columns(columns:int):void {
			this._columns = columns;
		}
		
		/**
		 * Cálcula dimensões dos Panels
		 */
		private function calcDefaultDimensions():void {
			var dWidth:int = this.width;
			
			if (this.verticalScrollBar) {
				dWidth = dWidth - this.verticalScrollBar.width;
			}
			
			dWidth = dWidth - this.getStyle("paddingLeft"); //retira a borda esquerda
			dWidth = dWidth - this.getStyle("paddingRight"); //retira a borda direita
			dWidth = dWidth - (this._columns - 1) * 10; // espaco entre as colunas
			dWidth = dWidth / _columns;
			this.defaultWidth = dWidth - dWidth % 10;
			
			var dHeight:int = this.height;
			dHeight = dHeight - this.getStyle("paddingTop"); //retira a borda superior
			dHeight = dHeight - this.getStyle("paddingBottom"); //retira a borda inferior
			dHeight = dHeight - (this._rows - 1) * 10; // espaco entre as linhas
			dHeight = dHeight / _rows;
			this.defaultHeight = dHeight - dHeight % 10;
		}
		
		/**
		 * Cria o Grid que será apresentado como plano de fundo ao usuário
		 * para distinguir o layout.
		 **/
		private function createGrid():void {
			this.grid = new Canvas();
			this.grid.alpha = 0.2;
			this.grid.setStyle("borderSkin", RepeatedBackground);
			this.grid.setStyle("backgroundImage", SuperPanelEmbbedImagesSource.grid);
			this.grid.clipContent = false;
			this.grid.x = 0;
			this.grid.y = 0;
			this.grid.height = this.height;
			this.grid.width = this.width;
		}
		
		/**
		 * Identifica se o grid deve ser mostrado ou não.
		 *
		 * @param show - parâmetro booblean que identifica se o grid vai ser mostrado ou não.
		 **/
		public function set showGrid(show:Boolean):void {
			if (show && grid == null) {
				this.createGrid();
				this.rawChildren.addChildAt(grid, 0);
			} else if (!show && grid != null) {
				this.rawChildren.removeChild(grid);
				this.grid = null;
			}
		}
	}
}
