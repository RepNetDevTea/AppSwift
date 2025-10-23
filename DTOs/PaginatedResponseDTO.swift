//
//  PaginatedResponseDTO.swift
//  RepNet
//
//  Created by Angel Bosquez on 09/10/25.
//
// este archivo define un dto generico para manejar las respuestas "paginadas" de la api.
// paginacion es cuando la api nos envia muchos datos en pedazos o "paginas".
//
//POR EL MOMENTO NO USAMOS PAGINACION

import Foundation

// este es un dto generico. la `t` es un placeholder para cualquier tipo de dato que sea `decodable`.
// asi, podemos usar `paginatedresponsedto<reportdto>` o `paginatedresponsedto<sitedto>`
// sin tener que crear un struct nuevo para cada uno.
struct PaginatedResponseDTO<T: Decodable>: Decodable {
    // el arreglo de items para la pagina actual (ej. una lista de reportes).
    let items: [T]
    // los metadatos de la paginacion (pagina actual, total de paginas, etc.).
    let meta: PaginationMetadataDTO
}

// este dto contiene toda la informacion sobre la paginacion en si.
// nos ayuda a saber cuantas paginas hay, en cual estamos, etc.
struct PaginationMetadataDTO: Decodable {
    // el numero total de items en la base de datos para esta consulta.
    let totalItems: Int
    // cuantos items vienen en esta pagina actual.
    let itemCount: Int
    // el maximo de items que puede tener una pagina.
    let itemsPerPage: Int
    // el numero total de paginas disponibles.
    let totalPages: Int
    // la pagina actual que estamos viendo (ej. pagina 2 de 10).
    let currentPage: Int
}
