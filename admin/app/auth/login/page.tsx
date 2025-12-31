'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { useAuthStore } from '@/src/store/auth';
import { toast } from '../../components/Toaster';
import Button from '../../components/Button';
import Input from '../../components/Input';
import Icon, { faEnvelope, faLock, faEye, faEyeSlash, faBox, faPhone } from '../../components/Icon';

export default function LoginPage() {
  const router = useRouter();
  const { login, isAuthenticated, isLoading } = useAuthStore();
  
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [errors, setErrors] = useState<{ identifier?: string; password?: string; general?: string }>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (isAuthenticated) {
      router.push('/dashboard');
    }
  }, [isAuthenticated, router]);

  const validate = () => {
    const newErrors: { identifier?: string; password?: string } = {};
    
    if (!identifier.trim()) {
      newErrors.identifier = 'Email or phone number is required';
    } else {
      // Check if it's an email or phone number
      const isEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(identifier.trim());
      const isPhone = /^[\d\s\-\+\(\)]+$/.test(identifier.trim()) && identifier.trim().replace(/\D/g, '').length >= 8;
      
      if (!isEmail && !isPhone) {
        newErrors.identifier = 'Please enter a valid email address or phone number';
      }
    }

    if (!password) {
      newErrors.password = 'Password is required';
    } else if (password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validate()) {
      return;
    }

    setIsSubmitting(true);
    setErrors({});

    try {
      await login(identifier.trim(), password);
      toast.success('Login successful! Redirecting...');
      // Small delay to ensure state is updated
      await new Promise(resolve => setTimeout(resolve, 100));
      router.push('/dashboard');
    } catch (error: any) {
      const errorMessage = error?.message || 'Login failed. Please check your credentials.';
      setErrors({
        general: errorMessage,
      });
      toast.error(errorMessage);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen flex">
      {/* Left Side - Login Form */}
      <div className="w-full lg:w-[40%] flex items-center justify-center p-6 sm:p-8 lg:p-12 bg-white">
        <div className="w-full max-w-sm">
          {/* Logo */}
          <div className="mb-8">
            <div className="w-16 h-16 bg-[#0e1a30] rounded-full flex items-center justify-center mb-4">
              <Icon icon={faBox} className="text-white" size="2x" />
            </div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Log In to Zoea</h1>
            <p className="text-sm text-gray-600">
              Admin Portal - Manage Your Platform
            </p>
          </div>

          {/* Error Message */}
          {errors.general && (
            <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-sm text-sm text-red-600">
              {errors.general}
            </div>
          )}

          {/* Login Form */}
          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Email or Phone Field */}
            <div>
              <label htmlFor="identifier" className="block text-sm font-medium text-gray-700 mb-2">
                Email or Phone Number
              </label>
              <div className="relative">
                <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400">
                  <Icon 
                    icon={identifier.includes('@') ? faEnvelope : faPhone} 
                    size="sm" 
                  />
                </div>
                <input
                  id="identifier"
                  type="text"
                  value={identifier}
                  onChange={(e) => {
                    setIdentifier(e.target.value);
                    if (errors.identifier) setErrors({ ...errors, identifier: undefined });
                  }}
                  className={`w-full pl-10 pr-4 py-2.5 bg-gray-50 border rounded-sm text-gray-900 placeholder-gray-500 focus:outline-none focus:bg-white focus:ring-1 text-sm ${
                    errors.identifier
                      ? 'border-red-300 focus:border-red-500 focus:ring-red-500'
                      : 'border-gray-200 focus:border-[#0e1a30] focus:ring-[#0e1a30]'
                  }`}
                  placeholder="Enter your email or phone number"
                  required
                  disabled={isSubmitting || isLoading}
                />
              </div>
              {errors.identifier && (
                <p className="mt-1 text-sm text-red-600">{errors.identifier}</p>
              )}
            </div>

            {/* Password Field */}
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                Password
              </label>
              <div className="relative">
                <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400">
                  <Icon icon={faLock} size="sm" />
                </div>
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => {
                    setPassword(e.target.value);
                    if (errors.password) setErrors({ ...errors, password: undefined });
                  }}
                  className={`w-full pl-10 pr-12 py-2.5 bg-gray-50 border rounded-sm text-gray-900 placeholder-gray-500 focus:outline-none focus:bg-white focus:ring-1 text-sm ${
                    errors.password
                      ? 'border-red-300 focus:border-red-500 focus:ring-red-500'
                      : 'border-gray-200 focus:border-[#0e1a30] focus:ring-[#0e1a30]'
                  }`}
                  placeholder="Enter your password"
                  required
                  disabled={isSubmitting || isLoading}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  tabIndex={-1}
                >
                  <Icon icon={showPassword ? faEyeSlash : faEye} size="sm" />
                </button>
              </div>
              {errors.password && (
                <p className="mt-1 text-sm text-red-600">{errors.password}</p>
              )}
            </div>

            {/* Forgot Password */}
            <div className="flex items-center justify-end">
              <Link
                href="/auth/forgot-password"
                className="text-sm text-[#0e1a30] hover:text-[#0b1526] font-medium"
              >
                Forgot Password?
              </Link>
            </div>

            {/* Submit Button */}
            <Button
              type="submit"
              variant="primary"
              size="lg"
              loading={isSubmitting || isLoading}
              className="w-full"
            >
              Sign In
            </Button>
          </form>

          {/* Sign Up Link */}
          <div className="mt-6 text-center">
            <p className="text-sm text-gray-600">
              Don't have an account?{' '}
              <span className="text-[#0e1a30] font-medium">Contact administrator</span>
            </p>
          </div>

          {/* Footer */}
          <div className="mt-12 text-center">
            <p className="text-xs text-gray-500 mb-2">© {new Date().getFullYear()} Zoea Africa</p>
            <p className="text-xs text-gray-500">
              Discover Rwanda Like Never Before
            </p>
          </div>
        </div>
      </div>

      {/* Right Side - Cover Image */}
      <div className="hidden lg:flex lg:w-[60%] relative bg-gradient-to-br from-[#0e1a30] via-[#08101c] to-[#050b12]">
        {/* Pattern overlay */}
        <div className="absolute inset-0 opacity-10">
          <div className="absolute inset-0" style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
          }}></div>
        </div>
      </div>
    </div>
  );
}
