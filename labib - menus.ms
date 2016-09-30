/* #######################################################################################################################

	2017 Christophe Pages (http://www.c-pages.fr) 

##########################################################################################################################
	
	Bibiotheque d'assets 
	
##########################################################################################################################

	Structs regroupant les differents menus ( clique droit et menu de la fen�tre principale )
	
######################################################################################################################## */ 




------------------------------------------------------------- ------------------------------------------
-------declaration (a voir comment pas la faire en global)  ------------------------------------------
------------------------------------------------------------- ------------------------------------------





-------------------------------------------------------------
------- le struct ------------------------------------------
-------------------------------------------------------------
struct menu_struct (
	
	public 
	
		fn elements = (
			
			rcMenu rcMenuElements
			(
				------- le menu ------------------------------------------
				menuItem importer 				"Importer" 
				
				subMenu  "Options d'import" (
					
					menuItem importerBrut 			"Brut" 			checked:true
					menuItem importerCollapsed 	"Collapsed" 		
					menuItem importerProxy 		"Proxy"
					
				)
			
				seperator sep03
				
				menuItem nouveauDossier 	"Nouveau dossier" 
				
				seperator sep01				
				
				menuItem Ourvir 			"Ourvir" 
				menuItem OurvirExplo 		"Ourvir dans l'explorateur" 
				
				
				seperator sep08
				subMenu  "Supprimer" (
					menuItem 	supprimer 			"de Labib" 
					menuItem 	supprimerDD 		"de Labib et du DD"
				)
				
				seperator sep02
				
				subMenu  "Affichage" (
					
					menuItem	affichage_liste 				"Liste"			checked:( labib.fenetre.affichageLV == #liste )
					menuItem 	affichage_appercus	"Appercus"	checked:( labib.fenetre.affichageLV == #apercus )
					
-- 					seperator sep09
-- 					
-- 					menuItem 	affichage_recursif	"Recursif"	-- checked:( labib.fenetre.affichageLV == #apercus )
				)
				
				subMenu  "Trier par" (
					
					menuItem	trier_croissant 		"Ordre croissant"			checked:true
					menuItem	trier_decroissant 	"Ordre d�croissant"	
					
					seperator sep10
					
					menuItem	trier_nom 			"Noms"					checked:true
					menuItem	trier_date 			"Date"	
					menuItem	trier_nbrVertex 	"Nombre de vertex"
					menuItem	trier_nbrImports 	"Nombre d'imports"	
					
				)
				
				seperator sep04
				
				subMenu  "Fen�tres" (
					menuItem infos 		"Infos" 
					menuItem apercus 	"Aper�us" 
					
				)
				------- les evenements ------------------------------------------
				
				on nouveauDossier 		picked do	labib.nouveauDossier ()		
				
				on supprimer 				picked do 	labib.supprimer 	labib.fenetre.selectionElements
					
				on affichage_liste 		picked do	labib.fenetre.definirAffichage  #liste
				on affichage_appercus 	picked do	labib.fenetre.definirAffichage  #apercus
			
			)
			
			popUpMenu 	rcMenuElements
			
		),
		
		
		fn arbo = (
			debug "creerMenuTest"
			-------------------------------------------------------------
			------- le menu ------------------------------------------
			-------------------------------------------------------------
			rcMenu rcMenuDossiers
			(
				------- le menu ------------------------------------------
				subMenu  "Nouvel Asset" (
					menuItem nouvelAsset 				"Fichier"
					menuItem nouvelAssetDossier 	"Dossier"
				)
				
				seperator sep01
				menuItem nouveauDossier 	"Nouveau dossier" 
				menuItem renommer 			"Renommer" 
				
				seperator sep02
				
				menuItem supprimer 			"Supprimer"
				
				seperator sep03
				
				menuItem expandAll 			"Expand all"
				
				seperator sep04
				
				menuItem rechercheAvance 			"Recherche avanc�e"
				------- les evenements ------------------------------------------
				on nouveauDossier 			picked do	labib.nouveauDossier ()				
				on nouvelAsset 				picked do	labib.nouvelAsset ()				
				on nouvelAssetDossier 	picked do	labib.nouvelAssetDossier ()		
				on renommer 					picked do	labib.renommer ()	
				
				on supprimer 					picked do 	labib.supprimer 	#( labib.fenetre.selectionNoeud )
				
			)
			
			
			
			
			popUpMenu 	rcMenuDossiers
		),
		
		fn principal = (
			
			rcMenu rcPrincipal
			(
				---- menu ----
				subMenu "Edit"	(
					menuItem m_nouveauDossier 	"Nouveau dossier" 
					menuItem m_supprimer 			"Supprimer"					
				)
				subMenu "Vues" (
					menuItem m_afficherInfos 	"Infos"  	--	checked:( bibliotheque.getInfosOuvert() )
					menuItem m_afficherApercus	"Cr�ation des aper�us" 
				)
				subMenu "Pr�ferences"	(
					menuItem m_preferences 			"Pr�ferences" 
					menuItem m_resetPreferences 	"Reinitialiser" 
				)
				
				
				
				
				---- evenements ----
				on m_nouveauDossier picked do ()
				on m_supprimer picked do  ()
				
				on m_afficherInfos picked do ()
				on m_afficherApercus picked do ()
				
				on m_resetPreferences picked do 
					if queryBox "Etes-vous s�r de vouloir r�initialiser les pr�f�rences de la bibliotheque ?" do
						 ()				
				on m_preferences picked do  ()
				
			)
			return rcPrincipal
		)
		
)
