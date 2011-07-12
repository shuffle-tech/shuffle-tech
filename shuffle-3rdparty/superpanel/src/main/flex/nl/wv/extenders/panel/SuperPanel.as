/********************************************
   title   : SuperPanel
   version : 1.5
   author  : Wietse Veenstra
   website : http://www.wietseveenstra.nl
   date    : 2007-03-30
   updated : 2007-10-26
 ********************************************/
package nl.wv.extenders.panel {
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.controls.Button;
	import mx.controls.LinkButton;
	import mx.controls.scrollClasses.ScrollBar;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.effects.Move;
	import mx.effects.Parallel;
	import mx.effects.Resize;
	import mx.effects.easing.Exponential;
	import mx.events.EffectEvent;
	import mx.events.ResizeEvent;
	import mx.managers.CursorManager;
	
	/**
	 * Diparado quando o usuário pressiona o botão "Fechar."
	 *
	 * @eventType flash.events.Event.CLOSE
	 */
	[Event(name="close", type="flash.events.Event")]
	
	/**
	 * Disparado quando o evento de redimensionamento do SuperPanel é completado.
	 *
	 * @eventType nl.wv.extenders.panel.SuperPanel.RESIZE_COMPLETE
	 */
	[Event(name="resizeComplete", type="flash.events.Event")]
	
	/**
	 * Disparado quando o evento de maximizar do SuperPanel é completado.
	 *
	 * @eventType nl.wv.extenders.panel.SuperPanel.MAXIMIZE_COMPLETE
	 */
	[Event(name="maximizeComplete", type="flash.events.Event")]
	
	/**
	 * Disparado quando o evento de restaurar do SuperPanel é completado.
	 *
	 * @eventType nl.wv.extenders.panel.SuperPanel.RESTORE_COMPLETE
	 */
	[Event(name="restoreComplete", type="flash.events.Event")]
	
	/**
	 * O SuperPanel consiste em um painel com opções de redimensionar, arrastar e soltar, maximizar e restaurar.
	 *
	 * @author Wietse Veenstra
	 */
	public class SuperPanel extends Panel {
		
		/**
		 * Constante referente ao evento de resizeComplete.
		 */
		public static const RESIZE_COMPLETE:String = "resizeComplete";
		
		/**
		 * Constante referente ao evento de maximizeComplete.
		 */
		public static const MAXIMIZE_COMPLETE:String = "maximizeComplete";
		
		/**
		 * Constante referente ao evento de restoreComplete.
		 */
		public static const RESTORE_COMPLETE:String = "restoreComplete";
		
		/**
		 * Verifica se os controles do SuperPanel devem ser visualizados.
		 */
		[Bindable]
		public var showControls:Boolean = true;
		
		/**
		 * Verifica se o SuperPanel é redimensionável.
		 */
		private var _resizable:Boolean = true;
		
		/**
		 * Container que mantém os controles na barra de títulos.
		 */
		private var hBoxTitle:HBox = new HBox();
		
		/**
		 * Retorna se o SuperPanel é redimensionável.
		 *
		 * @return Se o SuperPanel é redimensionável.
		 */
		public function get resizable():Boolean {
			return this._resizable;
		}
		
		/**
		 * Define se o SuperPanel é redimensionável.
		 *
		 * @param data
		 *        Valor que define se o SuperPanel é redimensionável.
		 */
		[Bindable(event="resizableChange")]
		public function set resizable(data:Boolean):void {
			this.resizeHandler.visible = data;
			this.normalMaxButton.visible = data;
			this._resizable = data;
			dispatchEvent(new Event("resizableChange"));
		}
		
		/**
		 * Verifica se o SuperPanel pode ser movido.
		 */
		private var _movable:Boolean = true;
		
		/**
		 * Retorna se o SuperPanel pode ser movido.
		 *
		 * @return Valor indicando se o SuperPanel pode ser movido.
		 */
		public function get movable():Boolean {
			return this._movable;
		}
		
		/**
		 * Define se o SuperPanel pode ser movido.
		 *
		 * @param data
		 *        Valor que define se o SuperPanel pode ser movido.
		 */
		[Bindable(event="movableChange")]
		public function set movable(data:Boolean):void {
			this._movable = data;
			dispatchEvent(new Event("movableChange"));
		}
		
		/**
		 * Verifica se o SuperPanel pode ser fechado.
		 */
		private var _closable:Boolean = true;
		
		/**
		 * Define se o SuperPanel pode ser fechado.
		 *
		 * @param data
		 *        Valor que define se o SuperPanel pode ser fechado.
		 */
		public function get closable():Boolean {
			return this._closable;
		}
		
		/**
		 * Define se o SuperPanel é fechável.
		 *
		 * @param data
		 *        Valor que define se o SuperPanel é fechável.
		 */
		[Bindable(event="closableChange")]
		public function set closable(data:Boolean):void {
			//Para evitar que o objeto seja adicionado duas vezes ou removido duas vezes
			if (data == this._closable) {
				return;
			}
			this._closable = data;
			this._closableFlag = true;
			this.invalidateProperties();
			
			dispatchEvent(new Event("closableChange"));
		}
		
		/**
		 * Efetua o commit das propriedades do SuperPanel.
		 */
		override protected function commitProperties():void {
			super.commitProperties();
			
			if (_closableFlag) {
				_closableFlag = false;
				var bar:UIComponent;
				
				if (this._headerBar) {
					bar = this._headerBar.getChildByName("controlBar") as UIComponent;
				} else {
					bar = this.pTitleBar;
				}
				
				if (this._closable) {
					hBoxTitle.addChild(this.closeButton);
					/* bar.addChild(this.closeButton); */
				} else if (hBoxTitle.contains(this.closeButton)) {
					hBoxTitle.removeChild(this.closeButton);
					/* bar.removeChild(this.closeButton); */
				}
			}
		}
		
		/**
		 * Flag indicando se o valor closable foi alterado.
		 */
		private var _closableFlag:Boolean = false;
		
		/**
		 * Referência ao title bar do SuperPanel.
		 */
		protected var pTitleBar:UIComponent;
		
		/**
		 * Header bar do SuperPanel.
		 */
		private var _headerBar:UIComponent;
		
		/**
		 * Largura atual do SuperPanel quando o mesmo não está maximizado.
		 */
		private var oW:Number;
		
		/**
		 * Altura atual do SuperPanel quando o mesmo não está maximizado.
		 */
		private var oH:Number;
		
		/**
		 * Posição X atual do SuperPanel quando o mesmo não está maximizado.
		 */
		private var oX:Number;
		
		/**
		 * Posição Y atual do SuperPanel quando o mesmo não está maximizado.
		 */
		private var oY:Number;
		
		/**
		 * Utilizado em cálculos internos do SuperPanel.
		 */
		public var oPosition:int;
		
		/**
		 * Botão de maximizar/restaurar do SuperPanel.
		 */
		protected var normalMaxButton:LinkButton = new LinkButton();
		
		/**
		 * Botão de fechar do SuperPanel.
		 */
		protected var closeButton:LinkButton = new LinkButton();
		
		/**
		 * Botão que manipula o redimensionamento do SuperPanel.
		 */
		protected var resizeHandler:Button = new Button();
		
		/**
		 * Utilizado em cálculos internos do SuperPanel.
		 */
		private var oPoint:Point = new Point();
		
		/**
		 * Utilizado em cálculos internos do SuperPanel.
		 */
		private var sPoint:Point = new Point();
		
		/**
		 * Identificador do cursor quando o mesmo está no modo de redimensionamento.
		 */
		private var resizeCur:Number = 0;
		
		/**
		 * Verifica se o SuperPanel pode ser maximizado.
		 */
		private var _maximized:Boolean = false;
		
		/**
		 * Efeito utilizado quando o SuperPanel é redimensionado.
		 */
		private var parallel:Parallel;
		
		/**
		 * Construtor padrão do SuperPanel.
		 */
		public function SuperPanel() {
			//Begin styles from assets/css/styles.css
			this.normalMaxButton.setStyle("fillColors", ["#5f89b9", "#697182", "#ffffff", "#eeeeee"]);
			this.closeButton.setStyle("fillColors", ["#5f89b9", "#697182", "#ffffff", "#eeeeee"]);
			this.resizeHandler.setStyle("highlightAlphas", [1, 0.33]);
			this.resizeHandler.setStyle("fillAlphas", [1, 0.16, 0.18, 1]);
			this.resizeHandler.setStyle("fillColors", ["#5f89b9", "#697182", "#ffffff", "#eeeeee"]);
			//End styles from assets/css/styles.css
			
			this.addEventListener(ResizeEvent.RESIZE, positionChildren, false, 0, true);
		}
		
		/**
		 * Efetua a criação dos componentes internos do SuperPanel.
		 */
		override protected function createChildren():void {
			/*
			 * SQA: O método createChildren geralmente ultrapassa de 20 linhas, por tratar da inicialização do
			 * componente. Neste caso, deve ser desconsiderado do SQA, este item.
			 */
			super.createChildren();
			
			this.pTitleBar = super.titleBar;
			
			this.doubleClickEnabled = true;
			
			if (this._headerBar) {
				this.pTitleBar.addChild(_headerBar);
				this._headerBar.x = 0;
				this._headerBar.y = 0;
				this._headerBar.percentWidth = 100;
				this._headerBar.percentHeight = 100;
			}
			
			if (resizable) {
				this.resizeHandler.width = 12;
				this.resizeHandler.height = 12;
				//Begin styles from assets/css/styles.css
				this.resizeHandler.styleName = "resizeHandler";
				//this.resizeHandler.setStyle("upSkin", SuperPanelEmbbedImagesSource.resizeHandler);
				//this.resizeHandler.setStyle("overSkin", SuperPanelEmbbedImagesSource.resizeHandler);
				//this.resizeHandler.setStyle("downSkin", SuperPanelEmbbedImagesSource.resizeHandler);
				//this.resizeHandler.setStyle("disabledSkin", SuperPanelEmbbedImagesSource.resizeHandler);
				//End styles from assets/css/styles.css
				this.rawChildren.addChild(resizeHandler);
				this.initPos();
			}
			
			if (showControls) {
				this.normalMaxButton.setStyle("paddingTop", -3);
				this.normalMaxButton.setStyle("paddingLeft", -3);
				this.normalMaxButton.setStyle("paddingBottom", 0);
				this.normalMaxButton.setStyle("paddingRight", 0);
				this.normalMaxButton.width = 10;
				this.normalMaxButton.height = 10;
				this.normalMaxButton.toolTip = "Maximizar";
				this.normalMaxButton.setStyle("icon", SuperPanelEmbbedImagesSource.maximize);
				
				this.closeButton.setStyle("paddingTop", -3);
				this.closeButton.setStyle("paddingLeft", -3);
				this.closeButton.setStyle("paddingBottom", 0);
				this.closeButton.setStyle("paddingRight", 0);
				this.closeButton.width = 10;
				this.closeButton.height = 10;
				this.closeButton.toolTip = "Fechar";
				this.closeButton.setStyle("icon", SuperPanelEmbbedImagesSource.close);
				
				hBoxTitle.addChild(this.normalMaxButton);
				hBoxTitle.addChild(this.closeButton);
				hBoxTitle.setStyle("horizontalAlign", "right");
				hBoxTitle.setStyle("verticalAlign", "middle");
				hBoxTitle.width = 30;
				hBoxTitle.height = 25;
				
				if (this._headerBar) {
					var controlBar:Container = this._headerBar.getChildByName("controlBar") as Container;
					/* hBoxTitle.x = this.width - hBoxTitle.width - 3; */
					controlBar.addChild(this.hBoxTitle);
					/* controlBar.addChild(this.normalMaxButton);
					 controlBar.addChild(this.closeButton); */
				} else {
					/* hBoxTitle.x = this.width - hBoxTitle.width - 3 ; */
					this.pTitleBar.addChild(this.hBoxTitle);
					/* this.pTitleBar.addChild(this.normalMaxButton);
					 this.pTitleBar.addChild(this.closeButton); */
				}
			}
			
			this.positionChildren();
			this.addListeners();
		}
		
		/**
		 * Salva a posição e o tamanho atual do componente.
		 */
		public function initPos():void {
			this.oW = this.width;
			this.oH = this.height;
			this.oX = this.x;
			this.oY = this.y;
			this.rawChildren.setChildIndex(this.resizeHandler, this.rawChildren.numChildren - 1);
		}
		
		/**
		 * Escuta o binding da largura da header, para poder remover quando o SuperPanel for fechado.
		 */
		private var headerWidthCW:ChangeWatcher;
		
		/**
		 * Escuta o binding da altura da header, para poder remover quando o SuperPanel for fechado.
		 */
		private var headerHeightCW:ChangeWatcher;
		
		/**
		 * Efetua o posicionamento dos componentes.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		private function positionChildren(e:Event = null):void {
			if (this._headerBar) {
				this._headerBar.x = 0;
				this._headerBar.y = 0;
				headerWidthCW = BindingUtils.bindProperty(this._headerBar, "width", this.pTitleBar, "width");
				headerHeightCW = BindingUtils.bindProperty(this._headerBar, "height", this.pTitleBar, "height");
			} else if (showControls) {
				this.hBoxTitle.x = this.unscaledWidth - this.hBoxTitle.width - 3;
				/*
				   this.normalMaxButton.buttonMode    = true;
				   this.normalMaxButton.useHandCursor = true;
				   this.normalMaxButton.x = this.unscaledWidth - this.normalMaxButton.width - 24;
				   this.normalMaxButton.y = 8;
				   this.closeButton.buttonMode	   = true;
				   this.closeButton.useHandCursor = true;
				   this.closeButton.x = this.unscaledWidth - this.closeButton.width - 8;
				   this.closeButton.y = 8;
				 */
			}
			
			if (resizable) {
				this.resizeHandler.y = this.unscaledHeight - resizeHandler.height - 1;
				this.resizeHandler.x = this.unscaledWidth - resizeHandler.width - 1;
			}
		}
		
		/**
		 * Adiciona os listeners no SuperPanel.
		 */
		public function addListeners():void {
			this.addEventListener(MouseEvent.CLICK, panelClickHandler, false, 0, true);
			
			// Removido para não alterar a ordem dos portlets no desktop
			// this.addEventListener(MouseEvent.MOUSE_WHEEL, panelReorder);
			this.pTitleBar.addEventListener(MouseEvent.MOUSE_DOWN, titleBarDownHandler, false, 0, true);
			this.pTitleBar.addEventListener(MouseEvent.MOUSE_UP, titleMouseUpHandler, false, 0, true);
			
			this.pTitleBar.addEventListener(MouseEvent.DOUBLE_CLICK, titleBarDoubleClickHandler, false, 0, true);
			
			if (showControls) {
				this.closeButton.addEventListener(MouseEvent.CLICK, closeClickHandler, false, 0, true);
				this.normalMaxButton.addEventListener(MouseEvent.CLICK, normalMaxClickHandler, false, 0, true);
			}
			
			if (resizable) {
				this.resizeHandler.addEventListener(MouseEvent.MOUSE_OVER, resizeOverHandler, false, 0, true);
				this.resizeHandler.addEventListener(MouseEvent.MOUSE_OUT, resizeOutHandler, false, 0, true);
				this.resizeHandler.addEventListener(MouseEvent.MOUSE_DOWN, resizeDownHandler, false, 0, true);
			}
		}
		
		/**
		 * Handler para remover o grid atrás do componente
		 *
		 * @param e - evento disparado pelo mouse
		 **/
		private function titleMouseUpHandler(e:MouseEvent):void {
			this.showGrid = false;
		}
		
		/**
		 * Evento disparado ao clicar no painel, onde o mesmo é reposicionado para a última posição do container pai,
		 * ficando mais o topo do container.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		public function panelClickHandler(event:MouseEvent):void {
			if (parent) { //.hasEventListener(MouseEvent.MOUSE_MOVE)
				parent.removeEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
			}
			
			// Verifica se o SuperPanel adicionado não é do tipo PopUp, para permitir o comportamento
			// de janelas de maneira habitual. Onde pode-se trocar o foco da janela que deseja-se setar
			// como visível.
			if (this.isPopUp == false) {
				this.parent.setChildIndex(this, this.parent.numChildren - 1);
			}
			this.panelFocusCheckHandler();
		}
		
		/**
		 * Trata o evento de mouseDown do titleBar.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		public function titleBarDownHandler(event:MouseEvent):void {
			if (!movable) {
				return;
			}
			
			parent.addEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler, false, 0, true);
			this.sPoint.x = parent.mouseX - (parent.mouseX % 10);
			this.sPoint.y = parent.mouseY - (parent.mouseY % 10);
			this.oPoint.x = this.x;
			this.oPoint.y = this.y;
		}
		
		/**
		 * Trata o evento de mouseMove no titleBar. Movimenta o SuperPanel acompanhando o cursor do mouse.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		public function titleBarMoveHandler(event:MouseEvent):void {
			var xPlus:int = 0;
			var yPlus:int = 0;
			
			if (parent != null) {
				parent.addEventListener(MouseEvent.MOUSE_UP, titleBarDragDropHandler, false, 0, true);
				this.parent.setChildIndex(this, this.parent.numChildren - 1);
				xPlus = parent.mouseX - (parent.mouseX % 10) - sPoint.x;
				yPlus = parent.mouseY - (parent.mouseY % 10) - sPoint.y;
				this.panelFocusCheckHandler();
				this.alpha = 0.5;
				
				//Limita a largura maxima a largura do container pai
				if ((oPoint.x + xPlus + this.width) > this.parentWidth) {
					xPlus = (this.parentWidth) - (this.parentWidth % 10) - this.width - oPoint.x;
				}
				this.move(oPoint.x + xPlus, oPoint.y + yPlus);
				
				showGrid = true;
			} else {
				showGrid = false;
			}
		}
		
		/**
		 * Trata o evento de mouseUp do titleBar. Se no momento do evento, estiver em cima de outro SuperPanel, troca
		 * a posição entre os SuperPanels.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		public function titleBarDragDropHandler(event:MouseEvent):void {
			this.showGrid = false;
			
			parent.removeEventListener(MouseEvent.MOUSE_UP, titleBarDragDropHandler);
			parent.removeEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
			this.alpha = 1.0;
			
			dispatchEvent(new Event(RESIZE_COMPLETE));
			
			//Quando o shift não estiver pressionado troca os elementos de lugar
			if (event.shiftKey || isPopUp) {
				return;
			}
			
			var dest:SuperPanel = null;
			
			var pt:Point = new Point(parent.mouseX, parent.mouseY);
			pt = Container(parent).localToContent(pt);
			
			//Obrigado a achar na mão, metodo parent.getObjectsUnderPoint( bugado
			for (var i:int = 0; i < this.parent.numChildren; i++) {
				var child:DisplayObject = this.parent.getChildAt(i);
				
				//Não mover para o mesmo local =D
				if (this == child) {
					continue;
				}
				
				//Se tiver fora no eixo X
				if (pt.x < child.x || pt.x > child.x + child.width) {
					continue;
				}
				
				//E estiver fora no eixo Y
				if (pt.y < child.y || pt.y > child.y + child.height) {
					continue;
				}
				
				dest = child as SuperPanel;
				break;
			}
			
			if (dest == null) {
				return;
			}
			
			var source:Rectangle = new Rectangle(this.oPoint.x, this.oPoint.y, this.width, this.height);
			var target:Rectangle = new Rectangle(dest.x, dest.y, dest.width, dest.height);
			
			this.forcePosition(target.x, target.y, target.width, target.height);
			dest.forcePosition(source.x, source.y, source.width, source.height);
			
			var oldPos:int = this.oPosition;
			this.oPosition = dest.oPosition;
			dest.oPosition = oldPos;
		}
		
		/**
		 * Verifica se o SuperPanel está com foco.
		 */
		public function panelFocusCheckHandler():void {
		/*
		   for (var i:int = 0; i < this.parent.numChildren; i++) {
		   var child:UIComponent = UIComponent(this.parent.getChildAt(i));
		   if (this.parent.getChildIndex(child) < this.parent.numChildren - 1) {
		   child.setStyle("headerColors", [0xC3D1D9, 0xD2DCE2]);
		   child.setStyle("borderColor", 0xD2DCE2);
		   } else if (this.parent.getChildIndex(child) == this.parent.numChildren - 1) {
		   child.setStyle("headerColors", [0xC3D1D9, 0x5A788A]);
		   child.setStyle("borderColor", 0x5A788A);
		   }
		   }
		 */
		}
		
		/**
		 * Maximiza o SuperPanel se o mesmo estiver no estado normal e vice-versa.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		public function titleBarDoubleClickHandler(event:MouseEvent):void {
			parent.removeEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
			parent.removeEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
			
			maximized = !maximized;
		}
		
		/**
		 * Trata o evento de endEffect do SuperPanel.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		public function endEffectEventHandler(event:EffectEvent):void {
			this.resizeHandler.visible = resizable;
		}
		
		/**
		 * Força o SuperPanel a redimensionar para os valores recebidos por parâmetro.
		 *
		 * @param xTo
		 *        O valor da nova posição X do SuperPanel.
		 * @param yTo
		 *        O valor da nova posição Y do SuperPanel.
		 * @param widthTo
		 *        O valor da nova largura do SuperPanel.
		 * @param heightTo
		 *        O valor da nova altura do SuperPanel.
		 */
		public function forcePosition(xTo:int, yTo:int, widthTo:int, heightTo:int):void {
			this.oW = widthTo;
			this.oH = heightTo;
			this.oX = xTo;
			this.oY = yTo;
			
			resize(xTo, yTo, widthTo, heightTo);
		}
		
		/**
		 * Redimensiona o SuperPanel, baseado nos parâmetros recebidos.
		 *
		 * @param xTo
		 *        O valor da nova posição X do SuperPanel.
		 * @param yTo
		 *        O valor da nova posição Y do SuperPanel.
		 * @param widthTo
		 *        O valor da nova largura do SuperPanel.
		 * @param heightTo
		 *        O valor da nova altura do SuperPanel.
		 */
		private function resize(xTo:int, yTo:int, widthTo:int, heightTo:int):void {
			if (parallel != null) {
				parallel.end();
				parallel = null;
			}
			
			if (widthTo < minWidth) {
				widthTo = minWidth;
			}
			
			if (heightTo < minHeight) {
				heightTo = minHeight;
			}
			
			parallel = new Parallel();
			parallel.target = this;
			parallel.duration = 1000;
			
			var resize:Resize = new Resize(this);
			resize.widthTo = widthTo;
			resize.heightTo = heightTo;
			resize.easingFunction = Exponential.easeInOut;
			parallel.addChild(resize);
			
			var move:Move = new Move(this);
			move.xTo = xTo;
			move.yTo = yTo;
			move.easingFunction = Exponential.easeInOut;
			parallel.addChild(move);
			
			parallel.play();
			
			parallel.addEventListener(EffectEvent.EFFECT_END, this.handleResizeEvent, false, 0.0, true);
		
		}
		
		/**
		 * Trata o término do efeito de redimencionamento da tela, disparando o evento de resize e ainda o de maximize
		 * ou restore, dependendo do estado em que se encontrava o SuperPanel.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		private function handleResizeEvent(event:EffectEvent):void {
			dispatchEvent(new Event(RESIZE_COMPLETE));
			
			if (this.maximized) {
				dispatchEvent(new Event(MAXIMIZE_COMPLETE));
			} else {
				dispatchEvent(new Event(RESTORE_COMPLETE));
			}
		}
		
		/**
		 * Altera o SuperPanel para o modo maximizado, caso esteja no modo normal, e vice-versa.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		public function normalMaxClickHandler(event:MouseEvent = null):void {
			this.showGrid = false;
			
			if (!resizable) {
				return;
			}
			
			if (!this._maximized) {
				this.initPos();
				resizeHandler.visible = false;
				//Redimenciona com defeito especial
				resize(0, 0, parent.width, parent.height);
				showScrollBar(false);
				
				if (this.pTitleBar) {
					this.pTitleBar.removeEventListener(MouseEvent.MOUSE_DOWN, titleBarDownHandler);
				}
				
				//Begin styles from assets/css/styles.css
				this.normalMaxButton.setStyle("icon", SuperPanelEmbbedImagesSource.restore);
				this.normalMaxButton.toolTip = "Restaurar";
				//End styles from assets/css/styles.css
				this._maximized = true;
			} else {
				resizeHandler.visible = resizable;
				//Redimenciona com defeito especial
				resize(this.oX, this.oY, this.oW, this.oH);
				
				showScrollBar(true);
				if (this.pTitleBar) {
					this.pTitleBar.addEventListener(MouseEvent.MOUSE_DOWN, titleBarDownHandler, false, 0, true);
				}
				
				//Begin styles from assets/css/styles.css
				this.normalMaxButton.setStyle("icon", SuperPanelEmbbedImagesSource.maximize);
				this.normalMaxButton.toolTip = "Maximizar";
				//End styles from assets/css/styles.css
				this._maximized = false;
			}
		}
		
		/**
		 * Realiza as alterações necessárias no portlet para que ele seja restaurado ao tamanho original.
		 */
		public function setRestore():void {
			if (!resizable) {
				return;
			}
			
			resizeHandler.visible = resizable;
			
			showScrollBar(true);
			this.pTitleBar.addEventListener(MouseEvent.MOUSE_DOWN, titleBarDownHandler);
			
			//Begin styles from assets/css/styles.css
			this.normalMaxButton.setStyle("icon", SuperPanelEmbbedImagesSource.maximize);
			this.normalMaxButton.toolTip = "Maximizar";
			//End styles from assets/css/styles.css
			this._maximized = false;
		}
		
		/**
		 * Define se é ou não para exibir o scroll bar vertical no container pai.
		 *
		 * @param show
		 *        Valor que indica se é para mostrar ou não o scroll no container pai.
		 */
		private function showScrollBar(show:Boolean):void {
			if (parent.hasOwnProperty("verticalScrollBar")) {
				var pScroll:ScrollBar = parent["verticalScrollBar"] as ScrollBar;
				
				if (pScroll == null) {
					return;
				}
				pScroll.visible = show;
			}
		}
		
		/**
		 * Efetua o fechamento do SuperPanel.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		public function closeClickHandler(event:MouseEvent = null):void {
			if (headerHeightCW != null) {
				headerHeightCW.unwatch();
				headerHeightCW = null;
			}
			
			if (headerWidthCW != null) {
				headerWidthCW.unwatch();
				headerWidthCW = null;
			}
			
			if (parent != null) { //.hasEventListener(MouseEvent.MOUSE_MOVE)
				parent.removeEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
			}
			
			var evt:Event = new Event(Event.CLOSE);
			dispatchEvent(evt);
			
			if (parent != null) {
				this.parent.removeChild(this);
			}
			
			this.removeEventListener(MouseEvent.CLICK, panelClickHandler);
			
			this.showGrid = false;
			this._headerBar = null;
			this.pTitleBar = null;
		}
		
		/**
		 * Trata o evento de mouseOut do resizeHandler, inserindo o cursor vinculado ao resize do componente.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		public function resizeOverHandler(event:MouseEvent):void {
			this.resizeCur = CursorManager.setCursor(SuperPanelEmbbedImagesSource.resizeCursor, 2, -8, -8);
		}
		
		/**
		 * Trata o evento de mouseOut do resizeHandler, removendo o cursor vinculado ao resize do componente.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		public function resizeOutHandler(event:MouseEvent):void {
			CursorManager.removeCursor(CursorManager.currentCursorID);
		}
		
		/**
		 * Trata o evento de mouseDown do resizeHandler, iniciando o redimencionamento da tela.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		public function resizeDownHandler(event:MouseEvent):void {
			parent.addEventListener(MouseEvent.MOUSE_MOVE, resizeMoveHandler, false, 0, true);
			parent.addEventListener(MouseEvent.MOUSE_UP, resizeUpHandler, false, 0, true);
			this.resizeHandler.addEventListener(MouseEvent.MOUSE_OVER, resizeOverHandler, false, 0, true);
			this.panelClickHandler(event);
			this.resizeCur = CursorManager.setCursor(SuperPanelEmbbedImagesSource.resizeCursor);
			this.oPoint.x = parent.mouseX - resizeHandler.mouseX + resizeHandler.width;
			this.oPoint.y = parent.mouseY - resizeHandler.mouseY + resizeHandler.height;
		}
		
		/**
		 * Trata o evento de mouseMove do resizeHandler, movendo-o acompanhando o mouse.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		public function resizeMoveHandler(event:MouseEvent):void {
			this.showGrid = true;
			this.alpha = 0.5;
			this.stopDragging();
			
			var xPlus:Number = (parent.mouseX + 5) - ((parent.mouseX + 5) % 10) - this.oPoint.x;
			var yPlus:Number = (parent.mouseY + 5) - ((parent.mouseY + 5) % 10) - this.oPoint.y;
			
			/*
			 * Tamanho tem q respeitar:
			 * - Maximmo largura do pai;
			 * - Minimo o minWidth setado;
			 * - Minimo 140 (parte do titulo + icones)
			 */
			if (parent.mouseX < parentWidth && this.oW + xPlus > this.minWidth && this.oW + xPlus > 140) {
				this.width = this.oW + xPlus;
			}
			
			if (this.oW + xPlus < this.minWidth) {
				this.width = this.minWidth + 10 - this.minWidth % 10;
			}
			
			/*
			 * - Minimo o minHeight setado;
			 * - Minimo 20 px (barra de titulo)
			 */
			if (this.oH + yPlus > this.minHeight && this.oH + yPlus > 20) {
				this.height = this.oH + yPlus;
			}
			
			if (this.oH + yPlus < this.minHeight) {
				this.height = this.minHeight + 10 - this.minHeight % 10;
			}
			
			this.positionChildren();
		}
		
		/**
		 * Trata o evento de mouseUp do resizeHandler.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		public function resizeUpHandler(event:MouseEvent):void {
			showGrid = false;
			
			parent.removeEventListener(MouseEvent.MOUSE_MOVE, resizeMoveHandler);
			dispatchEvent(new Event(RESIZE_COMPLETE));
			
			parent.removeEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
			CursorManager.removeAllCursors();
			this.resizeHandler.addEventListener(MouseEvent.MOUSE_OVER, resizeOverHandler, false, 0, true);
			this.initPos();
			this.alpha = 1.0;
		}
		
		/**
		 * Retorna a largura do container pai do SuperPanel.
		 *
		 * @return A largura do container pai do SuperPanel.
		 */
		private function get parentWidth():int {
			if (parent.hasOwnProperty("verticalScrollBar")) {
				var pScroll:ScrollBar = parent["verticalScrollBar"] as ScrollBar;
				
				if (pScroll == null) {
					return parent.width;
				}
				return parent.width - pScroll.width;
			}
			return parent.width;
		}
		
		/**
		 * Retorna se é possível maximizar o SuperPanel.
		 *
		 * @return Valor indicando se é possível maximizar o SuperPanel.
		 */
		public function get maximized():Boolean {
			return this._maximized;
		}
		
		/**
		 * Define se o SuperPanel é maximizável.
		 *
		 * @param max
		 *        Valor que define se o SuperPanel é maximizável.
		 */
		public function set maximized(max:Boolean):void {
			if (_maximized != max) {
				normalMaxClickHandler();
			}
		}
		
		/**
		 * Define o título do SuperPanel.
		 *
		 * @param value
		 *        Título do SuperPanel.
		 */
		override public function set title(value:String):void {
			if (this._headerBar) {
				var title:* = this._headerBar.getChildByName("title");
				title.text = value;
			} else {
				super.title = value;
			}
		}
		
		/**
		 * Define a barra do cabeçalho do SuperPanel.
		 *
		 * @param headerBar
		 *        Barra que será utilizado na barra do SuperPanel.
		 */
		public function set headerBar(headerBar:UIComponent):void {
			this._headerBar = headerBar;
		}
		
		/**
		 * Define se é para mostrar o grid no container pai do SuperPanel.
		 *
		 * @param show
		 *        Valor que define se é para mostrar o grid no container pai do SuperPanel.
		 */
		private function set showGrid(show:Boolean):void {
			try {
				this.parent["showGrid"] = show;
			} catch (e:Error) {
				//doesnt metter
			}
		}
		
		/**
		 * Reordena a posição dos SuperPanels no container pai.
		 *
		 * @param event
		 *        Evento disparado pelo Flex.
		 */
		private function panelReorder(e:MouseEvent):void {
			e.stopImmediatePropagation();
			
			var child:DisplayObject;
			var dest:DisplayObject;
			var i:int;
			
			/*
			 * SQA: É inviável quebrar este bloco em vários métodos, pois só iria tornar mais complicado o
			 * entendimento do código.
			 */
			if (e.currentTarget is SuperPanel) {
				if (SuperPanel(e.currentTarget).isPopUp == false) {
					if (e.delta < 0) {
						for (i = parent.numChildren - 1; i >= 0; i--) {
							child = parent.getChildAt(i);
							
							//Se tiver fora no eixo X
							if (parent.mouseX < child.x || parent.mouseX > child.x + child.width) {
								continue;
							}
							
							//E estiver fora no eixo Y
							if (parent.mouseY < child.y || parent.mouseY > child.y + child.height) {
								continue;
							}
							dest = child;
							break;
						}
					} else {
						for (i = 0; i < parent.numChildren; i++) {
							child = parent.getChildAt(i);
							
							//Se tiver fora no eixo X
							if (parent.mouseX < child.x || parent.mouseX > child.x + child.width) {
								continue;
							}
							
							//E estiver fora no eixo Y
							if (parent.mouseY < child.y || parent.mouseY > child.y + child.height) {
								continue;
							}
							dest = child;
							break;
						}
					}
					
					if (dest != null) {
						if (e.delta < 0) {
							dest.parent.setChildIndex(dest, 0);
						} else {
							dest.parent.setChildIndex(dest, dest.parent.numChildren - 1);
						}
					}
				}
			}
		}
		
		/**
		 * Define a largura do SuperPanel.
		 *
		 * @param value
		 *        O novo valor da largura do SuperPanel.
		 */
		override public function set width(value:Number):void {
			if (_resizable) {
				super.width = value;
			}
		}
		
		/**
		 * Define a altura do SuperPanel.
		 *
		 * @param value
		 *        O novo valor da altura do SuperPanel.
		 */
		override public function set height(value:Number):void {
			if (_resizable) {
				super.height = value;
			}
		}
		
		/**
		 * Define a posição X do SuperPanel.
		 *
		 * @param value
		 *        O novo valor da posição X do SuperPanel.
		 */
		override public function set x(value:Number):void {
			if (_movable) {
				super.x = value;
			}
		}
		
		/**
		 * Define a posição Y do SuperPanel.
		 *
		 * @param value
		 *        O novo valor da posição Y do SuperPanel.
		 */
		override public function set y(value:Number):void {
			if (_movable) {
				super.y = value;
			}
		}
	}
}
