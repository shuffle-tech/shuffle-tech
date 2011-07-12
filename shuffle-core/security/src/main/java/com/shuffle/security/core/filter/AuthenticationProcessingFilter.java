package com.shuffle.security.core.filter;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AbstractAuthenticationProcessingFilter;

public class AuthenticationProcessingFilter extends
		AbstractAuthenticationProcessingFilter {

	private static final String DEFAULT_FILTER_PROCESSES_URL = "/login";
	private static final String POST = "POST";

	public AuthenticationProcessingFilter() {
		super(DEFAULT_FILTER_PROCESSES_URL);
	}

	@Override
	public Authentication attemptAuthentication(HttpServletRequest request,
			HttpServletResponse response) throws AuthenticationException,
			IOException, ServletException {
		// You'll need to fill in the gaps here. See the source of
		// UsernamePasswordAuthenticationFilter for a working implementation
		// you can leverage.
		return null;
	}

	@Override
	public void doFilter(ServletRequest req, ServletResponse res,
			FilterChain chain) throws IOException, ServletException {
		final HttpServletRequest request = (HttpServletRequest) req;
		final HttpServletResponse response = (HttpServletResponse) res;
		if (request.getMethod().equals(POST)) {
			// If the incoming request is a POST, then we send it up
			// to the AbstractAuthenticationProcessingFilter.
			super.doFilter(request, response, chain);
		} else {
			// If it's a GET, we ignore this request and send it
			// to the next filter in the chain. In this case, that
			// pretty much means the request will hit the /login
			// controller which will process the request to show the
			// login page.
			chain.doFilter(request, response);
		}
	}

}