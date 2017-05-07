//
//  PersistenciaDTO.swift
//  ProyectoFinalArqui
//
//  Created by Versatran on 5/3/17.
//  Copyright © 2017 Versatran. All rights reserved.
//

import Foundation

class PersistenciaDTO{
    var objeto:Any
    var usuario:String
    var password:String
    
    init(objeto:Any, usuario:String, password:String){
        self.objeto=objeto
        self.usuario=usuario
        self.password=password
    }
}
