package com.shuffle.security.core.user;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;
import javax.persistence.Transient;
import javax.persistence.UniqueConstraint;
import javax.validation.constraints.NotNull;

import org.hibernate.validator.constraints.NotEmpty;

@Entity
@Table(name = "USUARIO_SISTEMA", schema = "shuffle_tech", uniqueConstraints = { @UniqueConstraint(columnNames = {
		"ID_USUARIO", "NM_USUARIO" }) })
@NamedQueries({
		@NamedQuery(name = "usernameAndPassword", query = "SELECT u.username AS USERNAME, u.password AS PASSWORD FROM User u WHERE USERNAME=:username AND PASSWORD=:password"),
		@NamedQuery(name = "findUserByLoginName", query = "") })
public class ShuffleSystemUser implements Serializable {

	/**
	 * Serialization
	 */
	private static final long serialVersionUID = -5964707733741928818L;

	@Id
	@NotNull
	@Column(name = "NM_USUARIO", length = 50, updatable = false)
	private String username;
	@NotNull
	@Column(name = "DS_SENHA", length = 50, updatable = true)
	private String password;
	@NotNull
	@Column(name = "DS_EMAIL", length = 50, updatable = true)
	private String email;
	@Transient
	private Boolean authenticated;
	@NotNull
	@NotEmpty
	@Column(name = "SALT", length = 25, updatable = true)
	private String salt;

	/**
	 * @return
	 */
	public String getUsername() {
		return username;
	}

	/**
	 * @param username
	 */
	public void setUsername(String username) {
		this.username = username;
	}

	/**
	 * @return
	 */
	public String getPassword() {
		return password;
	}

	/**
	 * @param password
	 */
	public void setPassword(String password) {
		this.password = password;
	}

	/**
	 * @return
	 */
	public String getEmail() {
		return email;
	}

	/**
	 * @param email
	 */
	public void setEmail(String email) {
		this.email = email;
	}

	/**
	 * @return
	 */
	public Boolean getAuthenticated() {
		return authenticated;
	}

	/**
	 * @param authenticated
	 */
	public void setAuthenticated(Boolean authenticated) {
		this.authenticated = authenticated;
	}

	/**
	 * @return the salt
	 */
	public String getSalt() {
		return salt;
	}

	/**
	 * @param salt
	 *            the salt to set
	 */
	public void setSalt(String salt) {
		this.salt = salt;
	}
}
