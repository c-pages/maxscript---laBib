/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	LA BIBLIO
	Gestionnaires d'assets 3D, et peut etre plus tard de bitmaps et autre.
	
##########################################################################################################################
	
	Structs
	
	Regroupe differentes structures (potentielement r�utilisables )
	-	gestionnaire de ListView dotnet
	-	gestionnaire de TreeView dotnet
	-	structure permetant de dragger un dialog
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
	*v0.1 - [02/10/2016] -----------------------------------------------------------------------------
	- Mise en place globale 
########################################################################################################################*/




--------------------------------------------------------------------------------
----------	gerer un ListView dotnet 					--------------------
--------------------------------------------------------------------------------
struct str_listViewMgr (
		
	------------ DEBUG	----------------------------------------------------------------------------------
		m_debug = false,
-- 		m_debug = true,
		m_dbgPrefix ="LV",
		fn debug 	_txt  var:	 param:    =(
			if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		),
	----------------------------------------------------------------------------------------------------------
	
		
		
		
		
		
		------------ MEMBRES ----------------------------------
	public
		---- pointeurs (� donner en param a la creation) ----
		m_prt,										---- le parent, le rollout ---- ( a initialiser ) ----	
		m_ui, 										---- le listview a controler -- ( a initialiser ) ----
		m_TV,	
		m_prefs	=	m_prt.m_prefs,			---- les m_prefs de labib ---
		m_arbo	=	m_prt.m_arbo,
		m_edit	=	m_prt.m_prt.m_labib.edit,
	
	
	private
		---- pour la creation des items -----
		m_itemsAAfficher		= #(),
		m_iconesAAfficher,
		m_idImage 				= 0,
		
		---- affichage ----
		m_taille_icones,		
		
		---- couleurs ----
		m_col_uiFond,
		m_col_uiFondRecherche,	
		m_col_txtDossier,
		m_col_fondDossier,
		m_col_fondDossierPrt,			
		m_col_txt,		
		
		---- drag -----
		m_dragDropEffect=dotNetClass "System.Windows.Forms.DragDropEffects",
		
		---- les boutons de souris dotNet ----
		m_btnsDotNet = dotNetClass "System.Windows.Forms.MouseButtons",
		
		------------ FONCTIONS ----------------------------------
		
	public
	
		
		---- Creation d'un tiem ----
		fn creerItems 		_noeudsA 	= (
			
			---- on transforme "_elemsArbo" en array si element unique --
			toArray 	&_noeudsA
			
			for noeud  in _noeudsA do (
				
				
				---- le nouvel item ----
				local nvItem				= dotNetObject "System.Windows.Forms.ListViewItem" 	noeud.nomUnique
				nvItem.imageIndex 	= m_idImage
				nvItem.name 			= noeud.nomUnique
				
				---- le nouvel icone	 ----
				local	nvIcone 		= dotNetClass "System.Drawing.Image"
				
				--- Vue D�tail : la couleur des lignes  --
				if m_prefs.fenetre.affichageLV == #Details do (
					
					local idPaire = (  m_idImage / 2. - floor ( m_idImage / 2. ) ) == 0 
					local couleurLigne
					if idPaire	then couleurLigne 	= m_col_fondDossier
									else couleurLigne 	= m_col_uiFond
					if classof noeud == str_branche do
						couleurLigne -= [30,30,20] as color
					
					nvItem.BackColor		=	toCouleurDotnet	couleurLigne
					
				)			
				
				---- les differentes infos ---
				nvItem.text 			= noeud.nom
				
				nvItem.subItems.add 	( noeud.getNbrVertex () )
				nvItem.subItems.add 	( noeud.getDateDernierImport () )
				nvItem.subItems.add 	( noeud.getNbrImports ()   )
				nvItem.subItems.add 	( noeud.getAProxy ()  )
				nvItem.subItems.add 	( noeud.getAVueDetail ()   )		
				nvItem.subItems.add 	( noeud.getDateCreation ()  )
				
				/* m_ui.columns.add "Nom" 200
					m_ui.columns.add "Verts" 70
					m_ui.columns.add "Dernier import" 130
					m_ui.columns.add "Nbre d'imports" 70
					m_ui.columns.add "Proxy" 70
					m_ui.columns.add "D�tail" 70
					m_ui.columns.add "Cr�ation" 130
					
					m_ui.columns.add "Emplacement" 130
					m_ui.columns.add "Tags" 130				
					m_ui.columns.add "Lien" 130
					m_ui.columns.add "D�tail" 70
					m_ui.columns.add "Source manquante" 70 */
					
				-- remplissage en fonction de la classe de l'�l�ment --
				case classof noeud of (
					str_branche: (	--------------------------------------
						
						case  noeud.nomUnique  of (							
							"RETOUR":	(
								m_iconesAAfficher.images.add ( nvIcone.fromFile 	m_prefs.fenetre.apercuDossierParent )							

							)
							default:			(
								nvItem.text += "   (" + noeud.getNbrEnfants() as string + ")"
								m_iconesAAfficher.images.add ( nvIcone.fromFile 	m_prefs.fenetre.apercuDossier )
							)
						) -- fin case  noeud.nomUnique
						
					)
					str_element: (	--------------------------------------
						---- affichage du texte----
						nvItem.text 			= noeud.nom
						
						---- pour la vue image ----
						if noeud.apercu != undefined do
							if doesfileexist noeud.apercu 	then  m_iconesAAfficher.images.add 	( nvIcone.fromFile noeud.apercu )
																	else 	m_iconesAAfficher.images.add 	( nvIcone.fromFile m_prefs.fenetre.apercuVide )
					)					
				) -- fin case classof noeud 
				
				-- on ajoute le nouveau noeud � la liste de creation ---
				append m_itemsAAfficher	 nvItem
				m_idImage += 1
			) -- fin for noeud  in _noeudsA 
			
		),
		
		
		---- Accession ----
		fn	getNoeud 			_item 	= (
			m_arbo.getParNomUnique _item.name
		),
		fn	getItem 			_noeudA 	= (
			local	result = undefined
			for i=0 to  m_ui.items.count - 1 do (
				local elemLV  = m_ui.items.item[i]  
				if elemLV.name == _noeudA.nomUnique do
					result = elemLV
			)
			result
		),
		fn getNoeudA_at 	_x  _y 	=(
			local noeudClique
			local	noeudTVClique = m_ui.GetItemAt  _x  _y 
			
			if noeudTVClique != undefined then
				noeudClique = m_arbo.getParNomUnique  noeudTVClique.name
			
			noeudClique
		),
		fn getDossierCourant 			=(
			m_edit.getDossier()
		),
		fn getSelection =(
			m_edit.getSelection ()
		),
		
		---- divers ----
		fn selectionner 	_noeudsA	= (
			
			debug "selectionner"
			debug "_noeudsA" var:_noeudsA	 param:#nom
			
			---- on transforme "_noeudsA" en array si noeud unique --
			toArray 	&_noeudsA
			
			-- si _noeudsA est valide --
			if _noeudsA.count > 0 and _noeudsA[1] != undefined do (
				
				-- on actualise la selection des elements --
				m_edit.setSelection 	_noeudsA
				
				-- on deselectionne tout ----
				for i=0 to m_ui.items.count - 1 do
					m_ui.items.item[i].selected=false
				
				-- on selectionne les nouveau --
				for noeudA in _noeudsA do (
					local noeudLV = getItem 	noeudA
					if noeudLV != undefined do 
						noeudLV.selected = true
				)
				
				-- scroll jusqu'au elements selectionn�s --
				if not m_edit.selectionEstVide()  do (
					local selectionUnique = (m_edit.getSelection())[1]
					if selectionUnique != undefined do
						if getItem	 selectionUnique != undefined do
							m_ui.EnsureVisible( ( getItem	 selectionUnique ).Index )
					)
			)
			
			debug "(selection fin) m_edit.getSelection" var:(m_edit.getSelection () )	 param:#nom
		),
		fn vider = (
			
			-- on vide la liste --
			m_ui.items.Clear()
			
			-- initialiser les membres ---
			m_idImage								= 0
			m_itemsAAfficher						= #()
			m_iconesAAfficher 					= dotNetObject "System.Windows.Forms.ImageList"
			m_iconesAAfficher.imageSize 		= dotNetObject "System.Drawing.Size" 	m_prefs.fenetre.tailleApercusLV 		m_prefs.fenetre.tailleApercusLV
			m_iconesAAfficher.ColorDepth 	= m_iconesAAfficher.ColorDepth.Depth24Bit
			
		),
		fn actualiserSelection 	=(
		
			m_edit.viderSelection ()
			
			for i = 0 to m_ui.SelectedItems.count - 1 do (
				-- on ajoute chaque noeud a la slection --
				elem = 	m_arbo.getParNomUnique 	 m_ui.SelectedItems.item[i].name
				if elem != undefined do 
					m_edit.addSelection 		elem
				
			)
			debug "selection" var:(m_edit.getSelection ()) param:#nom
		),
		fn actualiser  = (	
			debug "actualiser"
			
			-- on nettoie le terrain ---
			vider ()
			
			--- on actualise la branche courante --
			m_brancheCourante = getDossierCourant ()
			debug "m_brancheCourante" var:m_brancheCourante	 param:#nom
			if m_brancheCourante != undefined then (
				
				--- la couleur de fond du LV ---------
				local col_fondVue			
				if m_brancheCourante.nomUnique == "RECHERCHE"	
					then	col_fondVue 	= m_col_uiFondRecherche
					else	col_fondVue 	= m_col_uiFond
				m_ui.BackColor 				= toCouleurDotnet 	col_fondVue
				
				-- Affichage des dossiers --
				if m_prefs.fenetre.afficherDossier do (	
					
					----  retour ----
					if m_brancheCourante.NomUnique != "ROOT" and m_brancheCourante.NomUnique != "RECHERCHE" do  (
						creerItems 	m_arbo.retour
						m_arbo.retour.parent = m_brancheCourante.parent
					)
					
					---- Les dossiers enfants ----
					creerItems 	( m_brancheCourante.getNoeuds() )
				)
				
				---- les elements enfants----
				creerItems 	( m_brancheCourante.getElements() )
				
				--- on remplie la liste LV ----
				m_ui.LargeImageList = 	m_iconesAAfficher
				m_ui.items.addRange		m_itemsAAfficher
				
				---- on selectionne ----
				selectionner	( m_edit.getSelection() )
				
			) --else debug "dossier" var:dossier
			
			
		),
		fn ouvrir 	_noeudA 			=(
			local noeudCible 
			
			--- retour ? --					
			if _noeudA.nomUnique == "RETOUR" 
				then noeudCible =  	_noeudA.parent
				else	noeudCible =	_noeudA
			
			-- ouverture --
			m_edit.ouvrir		noeudCible
			
		),
		fn afficher	_noeudAOuvrir	  = (	
			debug "afficher"
			debug "_noeudAOuvrir Dbt" var:_noeudAOuvrir	 param:#nom
			
			--- on actualise la branche courante --
			if _noeudAOuvrir != undefined then (
				
				-- on nettoie le terrain ---
				vider ()
				
				
				--- la couleur de fond du LV ---------
				local col_fondVue			
				if _noeudAOuvrir.nomUnique == "RECHERCHE"	
					then	col_fondVue 	= m_col_uiFondRecherche
					else	col_fondVue 	= m_col_uiFond
				m_ui.BackColor 			= toCouleurDotnet 	col_fondVue
				
				-- Affichage des dossiers --
				if m_prefs.fenetre.afficherDossier do (	
					
					----  retour ----
					if _noeudAOuvrir.NomUnique != "ROOT" and _noeudAOuvrir.NomUnique != "RECHERCHE" do  (
						creerItems 	m_arbo.retour
						m_arbo.retour.parent = _noeudAOuvrir.parent
					)
					
					---- Les dossiers enfants ----
					creerItems 	( _noeudAOuvrir.getNoeuds() )
				)
				
				---- les elements enfants----
				creerItems 	( _noeudAOuvrir.getElements() )
				
				--- on remplie la liste LV ----
				m_ui.LargeImageList = 	m_iconesAAfficher
				m_ui.items.addRange		m_itemsAAfficher
-- 				
-- 				---- on selectionne ----
				selectionner	( m_edit.getSelection () )
				
			) --else debug "dossier" var:dossier
			
			
		),
		
		
		---- nom ----
		fn editerNom 	_noeudA = (
			
			local noeudAEditer = getItem		_noeudA
			selectionner _noeudA
			noeudAEditer.BeginEdit()
		),
		fn renommer 		_arg	  =(
			
			debug "renommer Dbt" var:m_selection	 param:#nom
			
			local nouveauNom 	= _arg.label
			local itemSelec 		= m_ui.items.item[_arg.item]
	 		local noeudARenommer = getNoeud 	itemSelec			
			m_selection = #(noeudARenommer)
			
			debug "nouveauNom" var:nouveauNom
			debug "itemSelect" var:itemSelec	 param:#name
			
			debug "noeudARenommer" var:noeudARenommer param:#nomUnique		
			
			if nouveauNom != undefined  and  noeudARenommer !=undefined do ( 
				
				noeudARenommer.nom 	= nouveauNom
				
				--ecriture du fichier ---
				noeudARenommer.enregistrer ()
				
				--- actualiser ----
				m_prt.actualiser ()
				selectionner noeudARenommer
				
			)
			debug "renommer Fin" var:m_selection	 param:#nom
			
		),
		
		
		---- La vue ----
		fn zoomer		_deltaArg 	= (
			debug "zoomer"
			
			local delta
			
			if _deltaArg > 0 
				then delta = 20
				else  delta = -20
				
			local tailleMin 		= 40
			local tailleMax 	= m_prefs.apercus.taille.x
			m_prefs.fenetre.tailleApercusLV += delta
			
			if  m_prefs.fenetre.tailleApercusLV < tailleMin do 
				m_prefs.fenetre.tailleApercusLV = tailleMin
			if m_prefs.fenetre.tailleApercusLV  > tailleMax  do 
				m_prefs.fenetre.tailleApercusLV = tailleMax 
			
			m_ui.LargeImageList.imageSize	= dotNetObject "System.Drawing.Size" 	m_prefs.fenetre.tailleApercusLV 		m_prefs.fenetre.tailleApercusLV
			
			actualiser ()
			
		),
		fn changerAffichage  	_nouvelAffichage		=(
			
			---- on vide les colonnes ----
			m_ui.columns.clear ()
			
			-- on actualise les m_prefs --
			m_prefs.fenetre.affichageLV = _nouvelAffichage
			
			---- on creer le nouvel affiochage ----
			case _nouvelAffichage  of (
				#details: (
					m_ui.view = (dotNetClass "system.windows.forms.view").details
					m_ui.columns.add "Nom" 200
					m_ui.columns.add "Verts" 70
					m_ui.columns.add "Date du dernier import" 130
					m_ui.columns.add "Nbre d'imports" 70
					m_ui.columns.add "Proxy" 70
					m_ui.columns.add "D�tail" 70
					m_ui.columns.add "Date de cr�ation" 130
					
					m_ui.columns.add "Emplacement" 130
					m_ui.columns.add "Tags" 130				
					m_ui.columns.add "Lien" 130
					m_ui.columns.add "D�tail" 70
					m_ui.columns.add "Source manquante" 70
					
					m_ui.FullRowSelect = true
				)
				#liste: (
					m_ui.view = (dotNetClass "system.windows.forms.view").list
					m_ui.Columns.add "Nom" 180
					m_ui.FullRowSelect = false
					m_ui.margin.all = 0
				)
				#grandeIcone: (
					m_ui.view = (dotNetClass "system.windows.forms.view").LargeIcon
					m_ui.Columns.add "Nom" 10
					m_ui.FullRowSelect = false
					m_ui.margin.all = 0
				)
				#petitIcone: (
					m_ui.view = (dotNetClass "system.windows.forms.view").SmallIcon
					m_ui.Columns.add "Nom" 10
					m_ui.FullRowSelect = false
					m_ui.margin.all = 0
				)
				#tuile: (
					uiview = (dotNetClass "system.windows.forms.view").Tile
					m_ui.Columns.add "Nom" 10
					m_ui.FullRowSelect = false
					m_ui.margin.all = 0
				)
			)
			
		),
		
		
		---- dragAndDrop ---
		fn drag_checkSurvol	 _arg = (
			
			_arg.Effect=_arg.AllowedEffect
			
			local testItem= m_ui.GetItemAt _arg.x _arg.y
			if testItem != undefined then (
				if testItem.name != "RECHERCHE" then (
					_arg.Effect=m_dragDropEffect.none
				) 
			) 		
		),	
		fn drag_demarrer 	_arg =(
			debug "drag_demarrer"
			
			debug "(drag_demarrer) getSelection" var:( m_edit.getSelection () )	 param:#nom
			m_edit.drag_demarrer 	( m_edit.getSelection() )
			
			--- demarrage du drag ----
			m_ui.doDragDrop 		_arg.item 		m_dragDropEffect.Move	
			
		),
		fn drag_recevoir 	_arg =(
			
			debug "drag_recevoir"
		
			local posDrop	= m_ui.PointToClient 	m_ui.MousePosition
			local noeudDest = getNoeudA_at 	posDrop.x 	posDrop.y
			if noeudDest != undefined do (
				---- si d�pose dans "retour" ---
				if noeudDest.nomUnique == "RETOUR" 
					do noeudDest = noeudDest.parent
				
				---- deplacement des noeuds ---
				m_edit.drag_finaliser 	noeudDest
			)
		),
		
		
		---- Souris ----
		fn clq_down		_arg	 	= (
			debug "clq_down"
			
			--- actualiser la selection ----
			local	noeudLVClique = m_ui.GetItemAt  _arg.x _arg.y
			debug "(clq_down) noeudLVClique" var:( noeudLVClique )	 param:#name
			
			--- un seul element selectionn�
			if m_ui.selectedItems.count <=1 then (
				debug "un seul elemnt selec"
				if noeudLVClique != undefined do ( 
					noeudAClique = m_arbo.getParNomUnique  noeudLVClique.name
					
					debug "(clq_down) noeudAClique" var:( noeudAClique )	 param:#nomUnique
					
					if noeudAClique != undefined do 
						m_edit.setSelection	noeudAClique
				debug "(clq_down) getSelection -1- " var:( m_edit.getSelection () )	 param:#nom
					
				)
			) else if m_ui.selectedItems.count > 1 do (
				debug "plusieurs elemnts selec"
				m_edit.viderSelection ()
				for  i =0 to m_ui.selectedItems.count-1 do (
					itemSelec = m_ui.selectedItems.item[i]
					m_edit.addSelection 	( getNoeud itemSelec )
				)
			)
			
			
			debug "(clq_down) getSelection" var:( m_edit.getSelection () )	 param:#nom
			
		),
		fn clq_up 			_arg 			= (
			debug "clq_up"
			debug "(clq_up) m_edit.getSelection" var:( m_edit.getSelection () )	 param:#nom
			
			if not m_edit.dragEnCours () do (
				
				local	noeudLVClique = m_ui.GetItemAt  _arg.x _arg.y				
				
				case _arg.button of (
					(m_btnsDotNet.Left): 		if not m_edit.dragEnCours ()	do	actualiserSelection ()
					(m_btnsDotNet.Middle): 		()
					(m_btnsDotNet.None): 		()
					(m_btnsDotNet.Right): 		(
						actualiserSelection () 
						m_prt.m_menus.elements ()
					)
					(m_btnsDotNet.XButton1): 	m_edit.m_hist.seDeplacer 1
					(m_btnsDotNet.XButton2):	m_edit.m_hist.seDeplacer -1
				)
			)
-- 			debug "m_selection" var:m_selection
-- 			m_prt.dragFlag = false
			
			debug "(clq_up fin) m_edit.getSelection" var:( m_edit.getSelection () )	 param:#nom
		),
		fn clq_double		_arg 			= (
			debug "clq_double"
			
			local noeudClique = (m_edit.getSelection ())[1]
			
			case classOf noeudClique of (
				str_element: 	m_prt.importer_scene 	noeudClique
				str_branche:	ouvrir		noeudClique
			)
		),
		
		
		---- clavier ----		
		fn key_down				_keyCode =(
			
			local touche = dotnetclass  "System.Windows.Forms.Keys"
-- 			show touche
			local selectionA = m_edit.getSelection ()
			if not m_edit.selectionEstVide ()
				do case _keyCode of (
						-- renommer --
						( touche.F2 ): 		editerNom	selectionA[1]
						-- supprimer --
						( touche.Delete ): 	m_edit.supprimer	selectionA
						-- ouvrir --
						( touche.Enter ): 	ouvrir		selectionA[1]
					)
			
		),
		
		
		---- Initialisation ----
		fn initialiser =(
				
			---- affichage ----
			m_taille_icones				= m_prefs.fenetre.tailleApercusLV
			
			---- couleurs ----
			m_col_uiFond 				 	= m_prefs.fenetre.col_uiFond
			m_col_uiFondRecherche	= m_prefs.fenetre.col_uiFondRecherche
		
			m_col_txtDossier 				= m_prefs.fenetre.col_txtDossier
			m_col_fondDossier 			= m_prefs.fenetre.col_fondDossier
			m_col_fondDossierPrt 		= m_prefs.fenetre.col_fondDossierPrt	
			m_col_txt						= m_prefs.fenetre.col_txt
			
			-- UI --
			m_ui.borderstyle 				= (dotnetclass "System.Windows.Forms.BorderStyle").None
			m_ui.showitemtooltips 		= true
			m_ui.gridlines 					= false
			m_ui.checkboxes 				= false
			m_ui.labeledit 					= true
			m_ui.MultiSelect				= true
			m_ui.HideSelection 			= false
			m_ui.allowdrop 				= true
			m_ui.AllowColumnReorder	= true
			m_ui.BackColor 				= toCouleurDotnet	m_col_uiFond
			m_ui.ForeColor 				= toCouleurDotnet   m_col_txt
			
		)
	
)	--- fin struct listView ----















