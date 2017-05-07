//
//  InterfazAdminConexion.swift
//  ProyectoFinalArqui
//
//  Created by Versatran on 5/3/17.
//  Copyright © 2017 Versatran. All rights reserved.
//

import Foundation


//interfaz para la inyeccion de dependencias de la clase AdminConexion
protocol InterfazAdminConexion{
    func inyectarAdminCouchbase(admin: CBLManager)
    func inyectarBaseDatos(base: CBLDatabase)
    func inyectarNumConexiones(numConexiones: Int)
    func inyectarConfiguracion(config: Configuracion)
}
