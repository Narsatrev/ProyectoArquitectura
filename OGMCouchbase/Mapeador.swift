//
//  Mapeador.swift
//  ProyectoFinalArqui
//
//  Created by Versatran on 5/3/17.
//  Copyright © 2017 Versatran. All rights reserved.
//

import Foundation

class Mapeador{
    
    init(){ }
    
    //convierte un objeto json a un diccionario, para facilitar la transformacion al objeto original
    func JsonADiccionario(jsonText:String)->NSDictionary{
        var diccionario:NSDictionary?
        if let datosBinarios = jsonText.data(using: String.Encoding.utf8) {
            do {
                diccionario = try JSONSerialization.jsonObject(with: datosBinarios, options: []) as? [String:AnyObject] as! NSDictionary
                
            } catch let error as NSError {
                print(error)
            }
        }
        return diccionario!
    }
    
    //Esto es un simple wrapper para las funciones de la libreria JSON Serializer, en el paquete de
    //utilidades. Recibe un objeto y devuelve su representacion en JSON
    func ObjetoAJson(objeto: Any)->String{
        return JSONSerializer.toJson(objeto)
    }

}
