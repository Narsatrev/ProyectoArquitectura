//
//  InterfazAdminPersistencia.swift
//  ProyectoFinalArqui
//
//  Created by Versatran on 5/3/17.
//  Copyright © 2017 Versatran. All rights reserved.
//

import Foundation


//
//  InterfazAdminConexion.swift
//  ProyectoFinalArqui
//
//  Created by Versatran on 5/3/17.
//  Copyright © 2017 Versatran. All rights reserved.
//

import Foundation


//interfaz para la inyeccion de dependencias de la clase AdminPersistencia
protocol InterfazAdminPersistencia{
    func inyectarAdminConexion(adminConexion: AdminConexion)
    func inyectarMapeador(mapper: Mapeador)
}
