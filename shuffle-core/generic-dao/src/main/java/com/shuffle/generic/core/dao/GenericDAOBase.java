package com.shuffle.generic.core.dao;

import java.io.Serializable;
import java.util.List;

import javax.persistence.EntityManager;

import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;

/**
 * @author Thiago A. de Souza Weber
 * @since 28/06/2011
 */
public abstract class GenericDAOBase<ID extends Serializable, T extends GenericDTOBase> implements
        IGenericDAO<ID, T> {

    private EntityManager entityManager;

    public GenericDAOBase(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    protected Session getSession() {
        return (Session) this.entityManager.getDelegate();
    }

    public EntityManager getEntityManager() {
        return entityManager;
    }

    public void setEntityManager(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    protected void fetchCriteria(Criteria criteria) {
    }

    public List<T> findAll() throws Exception {
        return findAll(null, true);
    }

    public List<T> findAll(String orderBy) throws Exception {
        return this.findAll(orderBy, true);
    }

    @SuppressWarnings("unchecked")
    public List<T> findAll(String orderBy, boolean ascending) throws Exception {      
        Criteria c = getSession().createCriteria(getPersistentClass());
        c.setResultTransformer(Criteria.DISTINCT_ROOT_ENTITY);
        this.fetchCriteria(c);

        if (orderBy != null) {
            this.addOrderBy(c, orderBy, ascending);
        }
        return c.list();
    }

    @SuppressWarnings("unchecked")
    public T get(ID id) throws Exception {
        Criteria c = getSession().createCriteria(getPersistentClass());
        c.add(Restrictions.eq("id", id));
        this.fetchCriteria(c);
        return (T) c.uniqueResult();
    }

    public T save(T dto) throws Exception {
        return realSave(dto);
    }

    @SuppressWarnings("unchecked")
    protected T realSave(T dto) {
        if (dto.getID() == null || (dto.getID().longValue() == 0)) {
            dto.setID(null);
            getSession().save(dto);
        } else {
            dto = (T) getSession().merge(dto);
        }
        return dto;
    }

    protected void addOrderBy(Criteria c, String orderBy, boolean ascending) {
        if (orderBy != null) {
            c.addOrder(ascending ? Order.asc(orderBy) : Order.desc(orderBy));
        }
    }

}
