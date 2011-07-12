package com.shuffle.security.core.authentication.jdbc;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.security.authentication.dao.SaltSource;
import org.springframework.security.authentication.encoding.PasswordEncoder;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.provisioning.JdbcUserDetailsManager;
import org.springframework.transaction.annotation.Transactional;

import com.shuffle.security.core.salt.SaltedUser;
import com.shuffle.security.core.service.IChangePassword;

public class ShuffleJdbcDaoImpl extends JdbcUserDetailsManager implements
		IChangePassword {

	private static final String SQL_QUERY = "UPDATE USERS SET PASSWORD = ? WHERE USERNAME = ?";

	@Autowired
	private PasswordEncoder passwordEncoder;
	@Autowired
	private SaltSource saltSource;

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.springframework.security.provisioning.JdbcUserDetailsManager#
	 * changePassword(java.lang.String, java.lang.String)
	 */
	public void changePassword(String username, String password) {
		UserDetails user = loadUserByUsername(username);
		String encodedPassword = passwordEncoder.encodePassword(password,
				saltSource.getSalt(user));
		getJdbcTemplate().update(SQL_QUERY, encodedPassword, username);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.springframework.security.core.userdetails.jdbc.JdbcDaoImpl#
	 * createUserDetails(java.lang.String,
	 * org.springframework.security.core.userdetails.UserDetails,
	 * java.util.List)
	 */
	@Override
	protected UserDetails createUserDetails(String username,
			UserDetails userFromUserQuery,
			List<GrantedAuthority> combinedAuthorities) {
		String returnUsername = userFromUserQuery.getUsername();

		if (!isUsernameBasedPrimaryKey()) {
			returnUsername = username;
		}

		return new SaltedUser(returnUsername, userFromUserQuery.getPassword(),
				userFromUserQuery.isEnabled(), true, true, true,
				combinedAuthorities, ((SaltedUser) userFromUserQuery).getSalt());
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.springframework.security.core.userdetails.jdbc.JdbcDaoImpl#
	 * loadUsersByUsername(java.lang.String)
	 */
	@Override
	protected List<UserDetails> loadUsersByUsername(String username) {
		return getJdbcTemplate().query(getUsersByUsernameQuery(),
				new String[] { username }, new RowMapper<UserDetails>() {
					public UserDetails mapRow(ResultSet rs, int rowNum)
							throws SQLException {
						String username = rs.getString(1);
						String password = rs.getString(2);
						boolean enabled = rs.getBoolean(3);
						String salt = rs.getString(4);
						return new SaltedUser(username, password, enabled,
								true, true, true,
								AuthorityUtils.NO_AUTHORITIES, salt);
					}
				});
	}

	/**
	 * @param username
	 * @param password
	 * @param email
	 */
	@Transactional
	public void createUser(String username, String password, String email) {
		getJdbcTemplate()
				.update("INSERT INTO USUARIO_SISTEMA (NM_USUARIO, DS_SENHA, DS_EMAIL, SALT) VALUES (?,?,true,CAST(RAND()*1000000000 AS VARCHAR))",
						username, password);
		getJdbcTemplate()
				.update("INSERT INTO GRUPO_USUARIO (ID_GRUPO, ID_USUARIO) SELECTE ID ID_GRUPO,? FROM GRUPO WHERE NM_GRUPO ='users'",
						username);
	}
}
