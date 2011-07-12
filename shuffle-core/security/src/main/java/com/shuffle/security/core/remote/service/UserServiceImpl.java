package com.shuffle.security.core.remote.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.flex.remoting.RemotingDestination;
import org.springframework.flex.remoting.RemotingInclude;
import org.springframework.stereotype.Service;

import com.shuffle.security.core.authentication.jdbc.ShuffleJdbcDaoImpl;

@Service("userService")
@RemotingDestination(channels = { "my-amf" })
public class UserServiceImpl implements IUserService {
	@Autowired
	ShuffleJdbcDaoImpl jdbcDao;
	
	
	/* (non-Javadoc)
	 * @see com.shuffle.security.core.remote.service.IUserService#changePassword(java.lang.String, java.lang.String)
	 */
	@RemotingInclude
	public void changePassword(String username, String password) {
		jdbcDao.changePassword(username, password);
	}


	/* (non-Javadoc)
	 * @see com.shuffle.security.core.remote.service.IUserService#createUser(java.lang.String, java.lang.String, java.lang.String)
	 */
	@Override
	@RemotingInclude
	public void createUser(String username, String password, String email) {
		jdbcDao.createUser(username, password, email);
	}
	
	
}
