//
//  Configuracion.swift
//  ProyectoFinalArqui
//
//  Created by Versatran on 5/3/17.
//  Copyright © 2017 Versatran. All rights reserved.
//

import Foundation

class Configuracion{
    
    var usuario:String
    var password:String
    var nombreBase:String
    var numActualizacionesSimultaneas:Int
    
    init(usuario:String, password:String, nombreBase:String, numActualizacionesSimultaneas:Int) {
        self.usuario=usuario
        self.password=password
        self.nombreBase=nombreBase
        self.numActualizacionesSimultaneas=numActualizacionesSimultaneas
    }
    
    func reporteConfig()->String{
        return "Usuario: " + self.usuario + "\n" + "Password: " + self.password + "\n" + "Nombre base: " + self.nombreBase+"\n" + "Actualizaciones simultaneas: " + String(self.numActualizacionesSimultaneas) + "\n"

    }
    
    
    
}
