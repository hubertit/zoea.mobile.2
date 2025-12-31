'use client';

import { useState } from 'react';
import Link from 'next/link';
import { toast } from '../../components/Toaster';
import Button from '../../components/Button';
import Input from '../../components/Input';
import Icon, { faEnvelope, faPhone, faArrowLeft, faBox } from '../../components/Icon';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [method, setMethod] = useState<'email' | 'phone'>('email');
  const [errors, setErrors] = useState<{ email?: string; phone?: string; general?: string }>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);

  const validate = () => {
    const newErrors: { email?: string; phone?: string } = {};
    
    if (method === 'email') {
      if (!email.trim()) {
        newErrors.email = 'Email is required';
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        newErrors.email = 'Please enter a valid email address';
      }
    } else {
      if (!phone.trim()) {
        newErrors.phone = 'Phone number is required';
      } else if (!/^\+?[1-9]\d{1,14}$/.test(phone.replace(/\s/g, ''))) {
        newErrors.phone = 'Please enter a valid phone number';
      }
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
      // TODO: Replace with actual API call
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL || 'https://zoea-africa.qtsoftwareltd.com/api'}/api/auth/password/reset/request`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          [method]: method === 'email' ? email.trim() : phone.trim(),
        }),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({ message: 'Failed to send reset code' }));
        throw new Error(errorData.message || 'Failed to send reset code');
      }

      setIsSubmitted(true);
      toast.success(`Reset code sent to your ${method === 'email' ? 'email' : 'phone'}`);
    } catch (error: any) {
      setErrors({
        general: error.message || 'Failed to send reset code. Please try again.',
      });
      toast.error(error.message || 'Failed to send reset code. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isSubmitted) {
    return (
      <div className="min-h-screen flex">
        <div className="w-full lg:w-[40%] flex items-center justify-center p-6 sm:p-8 lg:p-12 bg-white">
          <div className="w-full max-w-sm text-center">
            <div className="mx-auto w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mb-4">
              <Icon icon={faEnvelope} className="text-green-600" size="lg" />
            </div>
            <h2 className="text-2xl font-bold text-gray-900 mb-2">Check your {method === 'email' ? 'email' : 'phone'}</h2>
            <p className="text-gray-600 mb-6">
              We've sent a reset code to {method === 'email' ? email : phone}
            </p>
            <div className="space-y-4">
              <Link href="/auth/login">
                <Button variant="primary" className="w-full">
                  Back to Login
                </Button>
              </Link>
              <button
                onClick={() => {
                  setIsSubmitted(false);
                  setEmail('');
                  setPhone('');
                }}
                className="text-sm text-[#0e1a30] hover:text-[#0b1526]"
              >
                Didn't receive the code? Try again
              </button>
            </div>
          </div>
        </div>
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

  return (
    <div className="min-h-screen flex">
      {/* Left Side - Form */}
      <div className="w-full lg:w-[40%] flex items-center justify-center p-6 sm:p-8 lg:p-12 bg-white">
        <div className="w-full max-w-sm">
          {/* Logo */}
          <div className="mb-8">
            <div className="w-16 h-16 bg-[#0e1a30] rounded-full flex items-center justify-center mb-4">
              <Icon icon={faBox} className="text-white" size="2x" />
            </div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Forgot Password</h1>
            <p className="text-sm text-gray-600">
              Enter your email or phone to receive a reset code
            </p>
          </div>

          {/* Error Message */}
          {errors.general && (
            <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-sm text-sm text-red-600">
              {errors.general}
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Method Selection */}
            <div className="flex gap-2 p-1 bg-gray-100 rounded-sm">
              <button
                type="button"
                onClick={() => {
                  setMethod('email');
                  setErrors({});
                }}
                className={`flex-1 py-2 px-4 text-sm font-medium rounded-sm transition-colors ${
                  method === 'email'
                    ? 'bg-white text-[#0e1a30]'
                    : 'text-gray-600 hover:text-gray-900'
                }`}
              >
                Email
              </button>
              <button
                type="button"
                onClick={() => {
                  setMethod('phone');
                  setErrors({});
                }}
                className={`flex-1 py-2 px-4 text-sm font-medium rounded-sm transition-colors ${
                  method === 'phone'
                    ? 'bg-white text-[#0e1a30]'
                    : 'text-gray-600 hover:text-gray-900'
                }`}
              >
                Phone
              </button>
            </div>

            {method === 'email' ? (
              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                  Email Address
                </label>
                <div className="relative">
                  <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400">
                    <Icon icon={faEnvelope} size="sm" />
                  </div>
                  <input
                    id="email"
                    type="email"
                    value={email}
                    onChange={(e) => {
                      setEmail(e.target.value);
                      if (errors.email) setErrors({ ...errors, email: undefined });
                    }}
                    className={`w-full pl-10 pr-4 py-2.5 bg-gray-50 border rounded-sm text-gray-900 placeholder-gray-500 focus:outline-none focus:bg-white focus:ring-1 text-sm ${
                      errors.email
                        ? 'border-red-300 focus:border-red-500 focus:ring-red-500'
                        : 'border-gray-200 focus:border-[#0e1a30] focus:ring-[#0e1a30]'
                    }`}
                    placeholder="Enter your email"
                    required
                    disabled={isSubmitting}
                  />
                </div>
                {errors.email && (
                  <p className="mt-1 text-sm text-red-600">{errors.email}</p>
                )}
              </div>
            ) : (
              <div>
                <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-2">
                  Phone Number
                </label>
                <div className="relative">
                  <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400">
                    <Icon icon={faPhone} size="sm" />
                  </div>
                  <input
                    id="phone"
                    type="tel"
                    value={phone}
                    onChange={(e) => {
                      setPhone(e.target.value);
                      if (errors.phone) setErrors({ ...errors, phone: undefined });
                    }}
                    className={`w-full pl-10 pr-4 py-2.5 bg-gray-50 border rounded-sm text-gray-900 placeholder-gray-500 focus:outline-none focus:bg-white focus:ring-1 text-sm ${
                      errors.phone
                        ? 'border-red-300 focus:border-red-500 focus:ring-red-500'
                        : 'border-gray-200 focus:border-[#0e1a30] focus:ring-[#0e1a30]'
                    }`}
                    placeholder="Enter your phone number"
                    required
                    disabled={isSubmitting}
                  />
                </div>
                {errors.phone && (
                  <p className="mt-1 text-sm text-red-600">{errors.phone}</p>
                )}
              </div>
            )}

            <Button
              type="submit"
              variant="primary"
              size="lg"
              loading={isSubmitting}
              className="w-full"
            >
              Send Reset Code
            </Button>
          </form>

          {/* Back to Login */}
          <div className="mt-6 text-center">
            <Link
              href="/auth/login"
              className="flex items-center justify-center gap-2 text-sm text-gray-600 hover:text-[#0e1a30]"
            >
              <Icon icon={faArrowLeft} size="sm" />
              Back to Login
            </Link>
          </div>
        </div>
      </div>

      {/* Right Side - Cover */}
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
