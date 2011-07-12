package com.shuffle.security.core.authentication;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.jdbc.core.support.JdbcDaoSupport;
import org.springframework.security.authentication.dao.SaltSource;
import org.springframework.security.authentication.encoding.PasswordEncoder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;

import com.shuffle.security.core.user.SecurityUserDetails;

public class DatabasePasswordSecurerBean extends JdbcDaoSupport {
	private static final String SQL_QUERY = "SELECT NM_USUARIO AS USERNAME, DS_SENHA AS PASSWORD FROM USUARIO_SISTEMA";
	private static final Integer USERNAME_PARAM = 1;
	private static final Integer PASSWORD_PARAM = 2;

	@Autowired
	private PasswordEncoder passwordEncoder;
	@Autowired
	private SaltSource saltSource;
	@Autowired
	private UserDetailsService userDetailsService;

	public void secureDatabase() {
		getJdbcTemplate().query(SQL_QUERY, new RowCallbackHandler() {

			@Override
			public void processRow(ResultSet rs) throws SQLException {
				String username = rs.getString(USERNAME_PARAM);
				String password = rs.getString(PASSWORD_PARAM);

				SecurityUserDetails user = (SecurityUserDetails) userDetailsService
						.loadUserByUsername(username);
				String encodedPassword = passwordEncoder.encodePassword(
						password, saltSource.getSalt((UserDetails) user));

				getJdbcTemplate()
						.update("UPDATE USUARIO_SISTEMA SET DS_SENHA = ? WHERE NM_USUARIO = ?",
								encodedPassword, username);
				logger.debug("Updating password for username: " + username
						+ " to: " + encodedPassword);
			}
		});
	}
}
