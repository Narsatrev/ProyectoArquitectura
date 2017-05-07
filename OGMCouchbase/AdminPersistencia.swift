//
//  AdminPersistencia.swift
//  ProyectoFinalArqui
//
//  Created by Versatran on 5/3/17.
//  Copyright © 2017 Versatran. All rights reserved.
//

import Foundation


class AdminPersistencia: InterfazAdminPersistencia{
    
    var adminConexion: AdminConexion
    var mapeador: Mapeador
    
    //constructor privado, el admin de persistencia es tambien un singleton
    private init(){
        self.adminConexion=AdminConexion.generarInstancia
        self.mapeador=Mapeador.init()
    }
    
    //funciones que corresponden a la firma de las funciones en InerfazAdminPersistencia
    //son de gran utilidad para la inyeccion de dependencias
    func inyectarMapeador(mapper: Mapeador) {
        self.mapeador=mapper
    }
    
    func inyectarAdminConexion(adminConexion: AdminConexion) {
        self.adminConexion=adminConexion
    }
    
    //Metodo para recuperar la instancia del administrador de persistencia
    static let generarInstancia: AdminPersistencia = {
        let instancia = AdminPersistencia()
        return instancia
    }()
    
    func crearIdentificador()->String{
        let id_unico:String = NSUUID().uuidString
        return self.adminConexion.config.usuario+"."+id_unico
    }
    
    //produce un dto a partir de un objeto y las opciones de configuracion del administrador de conexion
    func construirDTO(objeto:Any)->PersistenciaDTO{
        let objetoDTO = PersistenciaDTO(objeto: objeto, usuario: self.adminConexion.config.usuario, password: self.adminConexion.config.password)
        return objetoDTO
    }
    
    //transforma el dto a formato json para facilitar su procesamiento posterior
    func transformarDtoAJson(dto:PersistenciaDTO)->String{
        return self.mapeador.ObjetoAJson(objeto:dto)
    }
    
    //transforma json a diccionario de tipo [String:Any] que es el tipo de objeto correcto
    //que admite couchbase como propiedades de un documento
    func transformarJsonADictStringAnyCompatiblePropiedades(dtoJson: String)->[String: Any]{
        let x =  try! JSONSerializer.toDictionary(dtoJson);
        let y = x["objeto"] as! [String:Any]
        var diccionarioCompatible = [String: Any]()
        
        var diccionarioObjeto = [String: Any]()
        for (value, key) in y {
            diccionarioObjeto[(value as? String)!] = key
        }
        
        diccionarioCompatible["objeto"] = diccionarioObjeto 
        diccionarioCompatible["usuario"] = x["usuario"] as! String
        diccionarioCompatible["password"] = x["password"] as! String
        
        return diccionarioCompatible;
    }
    
    //pipeline a seguir: objeto-> dto -> json ->(se le pegan usuario y password) -> diccionario compatible de tipo [String:Any]-> Guardar documento
    //NOTA: el metodo CrearNuevoDocumento() YA DEBE RECIBIR un [String:Any] para facilitar testing
    
    //CRUD: crear nuevo documento. Devuelve el identificador del mismo. *Utilizar transformarDtoAJson y construirDto para simplificar el proceso
    func crearNuevoDocumento(diccionarioCompatible:[String:Any])->String{
        let identificador:String = crearIdentificador()
        var mensajeFinal:String = identificador;
        
        guard let documento = self.adminConexion.base.document(withID: identificador) else {
            mensajeFinal="error al crear el documento (fase identificador)"
            return mensajeFinal
        }
        do{
            let documento_con_propiedades = try documento.putProperties(diccionarioCompatible)
            let revision = documento_con_propiedades.createRevision()
            do {
                try revision.saveAllowingConflict()
            } catch _ as NSError {
                mensajeFinal="error al crear el documento (fase guardado)"
            }
            
        } catch _ as NSError {
            mensajeFinal="error al crear el documento (fase asignacion propiedades)"
        }
        return mensajeFinal
    }
    
    
    //CRUD: leer un documento en particular, recibe el id del documento, si existe devuelve la representacion
    //en json del objeto que posteriormente sera pasada al mapper que producira una representacion en diccionario
    //desafortunadamente, no es posible realizar una transformacion a los objetos originales
    //pues Swift requiere saber a priori el tipo de los objetos, es decir se require que el objeto
    //se inicialice con el constructor adecuado incluso antes de obtener los parametros de la instancia!
    //lo cual es imposible...
    func leerDocumento(idDocumento: String) -> [String:Any]{
        guard let documento = self.adminConexion.base.existingDocument(withID: idDocumento)
            else{
                return ["error": "no se pudo encontrar el documento"]
        }
        var objetoJSON = documento.properties!["objeto"] as! [String:Any]
        objetoJSON["id"] = idDocumento
        
        return objetoJSON
    }
    
    //CRUD: actualizar un documento, recibe un objeto nuevo (que parse a json) que contiene el id del
    //documento que quiere actualizarse, las propiedades del documento (el contenido
    //actual del objeto persistido) se sustityten por las del nuevo objeto
    func actualizarDocumento(diccionarioNuevoObjetoReemplazo:[String:Any])->[String: Any]{
        let id=diccionarioNuevoObjetoReemplazo["id"]
        let objeto_json=diccionarioNuevoObjetoReemplazo["objeto"]
        let documento = leerDocumentoFormatoNativo(idDocumento: id as! String)
        do {
            try documento?.update { revisionActualizada in
                revisionActualizada["objeto"] = objeto_json
                var arrRes = revisionActualizada["objeto"] as! [String:Any];
                arrRes["id"] = id
                return true
            }
        } catch _ as NSError {
            return ["error": "error al actualizar el documento!"]
        }
        return diccionarioNuevoObjetoReemplazo
    }
    
    //metodo de utilidad que sera utilizada en el metodo de actualizacion de un documento, devuelve
    //la instancia del documento en cuestion (no una representacion temporal del pipeline)
    func leerDocumentoFormatoNativo(idDocumento:String)->CBLDocument?{
        let documento = self.adminConexion.base.existingDocument(withID: idDocumento)
        return documento
    }
    
    //CRUD: eliminar un documento, se requiere el ID del documento. Si se borra
    //exitosamente regresa un booleano verdadero, si por cualquier razon no se pudo borrar
    //(e.g. el documento no existe o no se tienen los permisos suficientes) regresa falso
    func eliminarDocumento(idDocumento: String)->Bool {
        guard let documento = self.adminConexion.base.existingDocument(withID: idDocumento)
            else{
                return false
        }
        do {
            try documento.delete()
            return true
        } catch _ as NSError {
            return false
        }
    }
    
    //CRUD: enlistado de todos los documentos en la base, regresa una lista de tuplas, donde cada
    //tupla representa el objeto como un diccionario con llaves string y valores de cualquier tipo
    func enlistar()-> [[String: Any]]{
        let query = self.adminConexion.base.createAllDocumentsQuery()
        query.allDocsMode = CBLAllDocsMode.allDocs
         let result = try! query.run()
        var todosDocumentos = [[String: Any]]()
        while let row = result.nextRow(){
            todosDocumentos.append(leerDocumento(idDocumento: row.documentID!));
        }
        return todosDocumentos
    }
    
    //CRUD: resetear la base de datos. Elimina todos los documentos de la base de datos. Utilizado particularmente
    //en las pruebas unitarias y de integración
    func resetearBase()-> Bool{
        let todosDocumentos = self.enlistar()
        var flagExito =  true
        for documento in todosDocumentos{
            flagExito = flagExito && self.eliminarDocumento(idDocumento: documento["id"]! as! String)
        }
        return flagExito
    }
    
    //Elimina la base de datos actual, utilizado principalmente para las pruebas unitarias
    func destruirBase(){
        try! self.adminConexion.base.delete()
    }
    
}

