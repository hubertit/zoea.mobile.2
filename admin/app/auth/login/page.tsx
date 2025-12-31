'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuthStore } from '@/src/store/auth';
import { toast } from '../../components/Toaster';
import Button from '../../components/Button';
import Input from '../../components/Input';
import Icon, { faEnvelope, faLock, faEye, faEyeSlash } from '../../components/Icon';
import Card, { CardHeader, CardBody, CardFooter } from '../../components/Card';

export default function LoginPage() {
  const router = useRouter();
  const { login, isAuthenticated, isLoading } = useAuthStore();
  
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [errors, setErrors] = useState<{ email?: string; password?: string; general?: string }>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (isAuthenticated) {
      router.push('/dashboard');
    }
  }, [isAuthenticated, router]);

  const validate = () => {
    const newErrors: { email?: string; password?: string } = {};
    
    if (!email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      newErrors.email = 'Please enter a valid email address';
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
      await login(email.trim(), password);
      toast.success('Login successful! Redirecting...');
      router.push('/dashboard');
    } catch (error: any) {
      setErrors({
        general: error.message || 'Login failed. Please check your credentials.',
      });
      toast.error(error.message || 'Login failed. Please check your credentials.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        {/* Logo/Header */}
        <div className="text-center">
          <div className="mx-auto w-16 h-16 bg-[#0e1a30] rounded-full flex items-center justify-center mb-4">
            <Icon icon={faLock} className="text-white" size="lg" />
          </div>
          <h2 className="text-3xl font-bold text-gray-900">Admin Portal</h2>
          <p className="mt-2 text-sm text-gray-600">Sign in to your account</p>
        </div>

        {/* Login Form */}
        <Card>
          <CardBody>
            <form onSubmit={handleSubmit} className="space-y-6">
              {errors.general && (
                <div className="bg-red-50 border border-red-200 rounded-sm p-3">
                  <p className="text-sm text-red-800">{errors.general}</p>
                </div>
              )}

              <Input
                label="Email Address"
                type="email"
                value={email}
                onChange={(e) => {
                  setEmail(e.target.value);
                  if (errors.email) setErrors({ ...errors, email: undefined });
                }}
                error={errors.email}
                leftIcon={faEnvelope}
                placeholder="Enter your email"
                autoComplete="email"
                required
              />

              <Input
                label="Password"
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => {
                  setPassword(e.target.value);
                  if (errors.password) setErrors({ ...errors, password: undefined });
                }}
                error={errors.password}
                leftIcon={faLock}
                rightIcon={showPassword ? faEyeSlash : faEye}
                onRightIconClick={() => setShowPassword(!showPassword)}
                placeholder="Enter your password"
                autoComplete="current-password"
                required
              />

              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <input
                    id="remember-me"
                    name="remember-me"
                    type="checkbox"
                    className="h-4 w-4 text-[#0e1a30] focus:ring-[#0e1a30] border-gray-300 rounded"
                  />
                  <label htmlFor="remember-me" className="ml-2 block text-sm text-gray-700">
                    Remember me
                  </label>
                </div>

                <div className="text-sm">
                  <Link
                    href="/auth/forgot-password"
                    className="font-medium text-[#0e1a30] hover:text-[#0b1526]"
                  >
                    Forgot password?
                  </Link>
                </div>
              </div>

              <Button
                type="submit"
                variant="primary"
                size="lg"
                loading={isSubmitting || isLoading}
                className="w-full"
              >
                Sign in
              </Button>
            </form>
          </CardBody>

          <CardFooter>
            <p className="text-center text-sm text-gray-600">
              Don't have an account?{' '}
              <Link
                href="/auth/register"
                className="font-medium text-[#0e1a30] hover:text-[#0b1526]"
              >
                Contact administrator
              </Link>
            </p>
          </CardFooter>
        </Card>

        {/* Footer */}
        <div className="text-center">
          <p className="text-xs text-gray-500">
            © {new Date().getFullYear()} Zoea Africa. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  );
}

