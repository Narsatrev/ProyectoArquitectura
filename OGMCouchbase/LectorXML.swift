//
//  LectorXML.swift
//  ProyectoFinalArqui
//
//  Created by Versatran on 5/4/17.
//  Copyright © 2017 Versatran. All rights reserved.
//

import Foundation


//clase que recupera los datos del archivo de configuracion, los parsea a datos (Data, representacion en bytes)
//y luego lo parse para generar una nueva configuracion
class LectorXML{
    
    var referenciaArchivoConfiguradion:NSDataAsset!
    var datosArchivoConfiguradion:Data!
    var contenidoArchivoConfiguradion:String!
    
    
    init(){
        self.referenciaArchivoConfiguradion = NSDataAsset(name: "config")
        self.datosArchivoConfiguradion = self.referenciaArchivoConfiguradion.data
        self.contenidoArchivoConfiguradion = String(data: self.datosArchivoConfiguradion,
                                                    encoding: String.Encoding.utf8) as String!
    }
    
    func imprimirContenidosArchivoConfig(){
        print(self.contenidoArchivoConfiguradion)
    }
    
    func generarConfiguracion()-> Configuracion{
        let contenidos = self.contenidoArchivoConfiguradion
        let paso1 : [String] = contenidos!.components(separatedBy: ">")
        let usuario_aux =  paso1[2].components(separatedBy: "<")[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let password_aux =  paso1[4].components(separatedBy: "<")[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let base_aux =  paso1[6].components(separatedBy: "<")[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let actualizacionesSimultaneas_aux =  paso1[8].components(separatedBy: "<")[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let config = Configuracion.init(usuario: usuario_aux, password: password_aux, nombreBase: base_aux, numActualizacionesSimultaneas: Int(actualizacionesSimultaneas_aux)!
        )
        
        return config
    }
    
}
