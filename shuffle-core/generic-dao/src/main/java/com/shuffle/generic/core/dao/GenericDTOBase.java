package com.shuffle.generic.core.dao;

import java.io.Serializable;

import javax.persistence.PrePersist;
import javax.persistence.PreUpdate;

/**
 * @author Thiago A. de Souza Weber
 * @since 28/06/2011
 */
public abstract class GenericDTOBase implements Serializable, Cloneable {

    /**
     * Serialization !
     */
    private static final long serialVersionUID = 1L;

    public abstract Long getID();

    public abstract void setID(Long id);

    public Long getIDLong() {
        return (Long) this.getID();
    }

    @Override
    public int hashCode() {
        return this.getID() == null ? System.identityHashCode(this) : this.getID().hashCode();
    }

    @Override
    public String toString() {
        return new StringBuilder(this.getClass().getName()).append(" id = ").append(this.getID()).toString();
    }

    @Override
    public boolean equals(Object obj) {
        if (this.getID() == null || !(obj instanceof GenericDTOBase)) {
            return false;
        }

        return this.getID().equals(((GenericDTOBase) obj).getID());
    }

    @PrePersist
    @PreUpdate
    public void prePersist() {
        if (this.getID().intValue() == 0) {
            this.setID(null);
        }
    }

    public Object clone() {
        try {
            GenericDTOBase dto = (GenericDTOBase) super.clone();
            dto.setID(null);
            return dto;
        } catch (CloneNotSupportedException e) {
            return null;
        }
    }
}
