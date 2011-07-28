package com.shuffle.generic.core.dao;

import java.io.Serializable;
import java.util.List;

/**
 * @author Thiago A. de Souza Weber
 * @since 28/06/2011
 */
public interface IGenericDAO<ID extends Serializable, T extends GenericDTOBase> {

    public Class<T> getPersistentClass();

    public T get(ID id) throws Exception;

    public T save(T dto) throws Exception;

    public List<T> findAll() throws Exception;

    public List<T> findAll(String orderBy, boolean ascending) throws Exception;

}
