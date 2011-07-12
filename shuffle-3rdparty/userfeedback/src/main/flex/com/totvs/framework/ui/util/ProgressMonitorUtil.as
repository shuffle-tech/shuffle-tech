/*
   Copyright (c) 2010, TOTVS S/A. Todos os direitos reservados.

   Os Programas desta Aplicação (que incluem tanto o software quanto a sua
   documentação) contém informações proprietárias da TOTVS S/A; eles são
   licenciados de acordo com um contrato de licença contendo restrições de uso e
   confidencialidade, e são também protegidos pela Lei 9609/98 e 9610/98,
   respectivamente Lei do Software e Lei dos Direitos Autorais. Engenharia
   reversa, descompilação e desmontagem dos programas são proibidos. Nenhuma
   parte destes programas pode ser reproduzida ou transmitida de nenhuma forma e
   por nenhum meio, eletrônico ou mecânico, por motivo algum, sem a permissão
   escrita da TOTVS S/A.
 */

package com.totvs.framework.ui.util {
	
	import com.datasul.framework.ui.progressmonitor.ProgressMonitor;
	
	import flash.display.DisplayObject;
	
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	/**
	 * Classe utilitária para utilização do componente ProgressMonitor. Auxilia
	 * na apresentação e remoção do monitor da tela.
	 *
	 * @author luiz.havryluk
	 */
	public class ProgressMonitorUtil {
		
		private static var instance:ProgressMonitorUtil;
		
		private var _progressMonitor:ProgressMonitor;
		
		/**
		 * Retorna a instância da classe ProgressMonitorUtil.
		 *
		 * @return
		 */
		public static function getInstance():ProgressMonitorUtil {
			if (instance == null) {
				instance = new ProgressMonitorUtil();
			}
			
			return instance;
		}
		
		/**
		 * Exibe o componente ProgressMonitor tendo o componente passado como
		 * componente pai do monitor.
		 *
		 * @param view - componente pai do monitor.
		 * @param modal - indica se o monitor será modal.
		 */
		public function showProgressMonitorHandler(view:DisplayObject, modal:Boolean = true):void {
			if (this._progressMonitor != null) {
				return;
			}
			
			// Verifica se o DisplayObject possui a propriedade isPopUp e se ela está como sim.
			// Esta verificação é feita porque o parent de uma popup é o SystemManager.
			if (view.hasOwnProperty("isPopUp") && view["isPopUp"]) {
				// Cria instancia para popup
				this._progressMonitor = PopUpManager.createPopUp(view, ProgressMonitor, modal) as ProgressMonitor;
				// Centraliza popup de feedback
				PopUpManager.centerPopUp(this._progressMonitor);
			} else {
				// Cria instancia para popup
				this._progressMonitor = PopUpManager.createPopUp(view, ProgressMonitor, modal) as ProgressMonitor;
				
				if (view.parent is UIComponent) {
					this._progressMonitor.dockParent = UIComponent(view.parent);
				}
				// Centraliza popup de feedback
				PopUpManager.centerPopUp(this._progressMonitor);
			}
		}
		
		/**
		 * Oculta o componente ProgressMonitor.
		 */
		public function hideProgressMonitorHandler():void {
			if (this._progressMonitor == null) {
				return;
			}
			
			// Remove popup progressmonitor
			PopUpManager.removePopUp(this._progressMonitor);
			// Retira referência do objeto
			this._progressMonitor = null;
		}
	
	}
}
