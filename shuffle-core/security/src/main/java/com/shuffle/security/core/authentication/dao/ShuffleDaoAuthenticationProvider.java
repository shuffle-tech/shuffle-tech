package com.shuffle.security.core.authentication.dao;

import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;

public class ShuffleDaoAuthenticationProvider extends DaoAuthenticationProvider {

	@Override
	public boolean supports(Class<? extends Object> authentication) {
		return (ShuffleUsernamePasswordAuthenticationToken.class
				.isAssignableFrom(authentication));
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * org.springframework.security.authentication.dao.DaoAuthenticationProvider
	 * #
	 * additionalAuthenticationChecks(org.springframework.security.core.userdetails
	 * .UserDetails, org.springframework.security.authentication.
	 * UsernamePasswordAuthenticationToken)
	 */
	@Override
	protected void additionalAuthenticationChecks(UserDetails userDetails,
			UsernamePasswordAuthenticationToken authentication)
			throws AuthenticationException {
		super.additionalAuthenticationChecks(userDetails, authentication);

		ShuffleUsernamePasswordAuthenticationToken signedToken = (ShuffleUsernamePasswordAuthenticationToken) authentication;

		if (signedToken.getRequestSignature() == null) {
			throw new BadCredentialsException(
					messages.getMessage(
							"SignedUsernamePasswordAuthenticationProvider.missingSignature",
							"Missing request signature"),
					isIncludeDetailsObject() ? userDetails : null);
		}

		// calculate expected signature
		if (!signedToken.getRequestSignature().equals(
				calculateExpectedSignature(signedToken))) {
			throw new BadCredentialsException(
					messages.getMessage(
							"SignedUsernamePasswordAuthenticationProvider.badSignature",
							"Invalid request signature"),
					isIncludeDetailsObject() ? userDetails : null);
		}
	}

	/**
	 * Given a signed token, calculates the signature value expected to be
	 * suppliled.
	 * 
	 * @param signedToken
	 *            the signed token to evaluate
	 * @return the expected signature
	 */
	private String calculateExpectedSignature(
			ShuffleUsernamePasswordAuthenticationToken signedToken) {
		return signedToken.getPrincipal() + "|+|"
				+ signedToken.getCredentials();
	}

}
