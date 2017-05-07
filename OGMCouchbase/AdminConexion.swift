//
//  AdminConexion.swift
//  ProyectoFinalArqui
//  Created by Versatran on 5/3/17.
//  Copyright © 2017 Versatran. All rights reserved.

import Foundation

class AdminConexion: InterfazAdminConexion{
    
    //atributos de la clase
    //contiene un cblmanager que es el punto de contacto directo con couchbase
    //base, que representa la instancia de la base de datos que sera manipulada
    //config, corresponde a los parametros de conexion parseados desde el archivo xml de configuracion
    //numConexiones es el numero actual de clientes conectados, se comparara constantemente con el 
    //varlo maximo permitido especificado en el archivo de configuracion xml
    var admin:CBLManager;
    var base: CBLDatabase;
    var config:Configuracion;
    var numConexiones: Int;
    
    //Constructor privado para la generacion de un singleton
    //contiene un monton de objetos temporales y dummies que seran reemplazados durante la inyeccion de dependencias
    private init() {
        admin=CBLManager.sharedInstance();
        let opcionesCreacion = CBLDatabaseOptions()
        opcionesCreacion.create = true
    
        //para debugging, configuracion inicial
//        config = Configuracion.init(usuario: "lolaxo", password: "sheller", nombreBase: "manashni", numActualizacionesSimultaneas: 30)
        
        let parseadorXML =  LectorXML.init()
        
        config = parseadorXML.generarConfiguracion()
        
        try! base=self.admin.openDatabaseNamed(self.config.nombreBase, with: opcionesCreacion);
        
        
        numConexiones=0;
    }
    
    //Metodo para recuperar la instancia del administrador
    static let generarInstancia: AdminConexion = {
        let instancia = AdminConexion()
        return instancia
    }()
    
    //crear nueva conexion por deafult,
    func crearNuevaConexionDefault()->String{
        self.inyectarAdminCouchbaseDefault()
        return crearNuevaConexion()
    }
    
    //metodo para generar una nueva conexion con couchbase
    //revisa si existe la base de datos, si no existe la crea de acuerdo a los parametros
    //del archivo xml de configuracion
    func crearNuevaConexion()->String{
        
        var mensajeExiste = "error"
        if(numConexiones<self.config.numActualizacionesSimultaneas){
            let existebaseDatos = self.admin.databaseExistsNamed(self.config.nombreBase)
            if(!existebaseDatos){
                let opcionesCreacion = CBLDatabaseOptions()
                opcionesCreacion.create = true
                try! self.base = self.admin.openDatabaseNamed(self.config.nombreBase, with: opcionesCreacion)
                                
                mensajeExiste = "no existe"
                print("No existe esa base")
            }else{
                try! self.base = self.admin.databaseNamed(self.config.nombreBase)
                
                mensajeExiste = "existe"
                print("Ya existe la base")
            }
            numConexiones=numConexiones+1;
            return mensajeExiste;
        }
        
        return mensajeExiste;
    }
    
    //para la inyeccion de dependencias y facilitar las pruebas unitarias
    //cumplir con las especificaciones del protocolo (interfaz) InterfazAdminConexion
    func inyectarAdminCouchbaseDefault(){
        inyectarAdminCouchbase(admin:CBLManager.sharedInstance())
    }
    
    func inyectarAdminCouchbase(admin: CBLManager){
        self.admin=admin;
    }
    func inyectarBaseDatos(base: CBLDatabase){
        self.base=base;
    }
    func inyectarNumConexiones(numConexiones:Int){
        self.numConexiones=numConexiones;
    }
    
    func inyectarConfiguracion(config: Configuracion){
        self.config=config;
    }
    
}
