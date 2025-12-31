'use client';

import { useState } from 'react';
import Link from 'next/link';
import { toast } from '../../components/Toaster';
import Button from '../../components/Button';
import Input from '../../components/Input';
import Icon, { faEnvelope, faPhone, faArrowLeft } from '../../components/Icon';
import Card, { CardHeader, CardBody, CardFooter } from '../../components/Card';

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
      <div className="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-md w-full space-y-8">
          <Card>
            <CardBody>
              <div className="text-center">
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
            </CardBody>
          </Card>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        {/* Header */}
        <div className="text-center">
          <div className="mx-auto w-16 h-16 bg-[#0e1a30] rounded-full flex items-center justify-center mb-4">
            <Icon icon={faEnvelope} className="text-white" size="lg" />
          </div>
          <h2 className="text-3xl font-bold text-gray-900">Forgot Password</h2>
          <p className="mt-2 text-sm text-gray-600">
            Enter your email or phone to receive a reset code
          </p>
        </div>

        {/* Form */}
        <Card>
          <CardBody>
            <form onSubmit={handleSubmit} className="space-y-6">
              {errors.general && (
                <div className="bg-red-50 border border-red-200 rounded-sm p-3">
                  <p className="text-sm text-red-800">{errors.general}</p>
                </div>
              )}

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
                      ? 'bg-white text-[#0e1a30] shadow-sm'
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
                      ? 'bg-white text-[#0e1a30] shadow-sm'
                      : 'text-gray-600 hover:text-gray-900'
                  }`}
                >
                  Phone
                </button>
              </div>

              {method === 'email' ? (
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
              ) : (
                <Input
                  label="Phone Number"
                  type="tel"
                  value={phone}
                  onChange={(e) => {
                    setPhone(e.target.value);
                    if (errors.phone) setErrors({ ...errors, phone: undefined });
                  }}
                  error={errors.phone}
                  leftIcon={faPhone}
                  placeholder="Enter your phone number"
                  autoComplete="tel"
                  required
                />
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
          </CardBody>

          <CardFooter>
            <Link
              href="/auth/login"
              className="flex items-center justify-center gap-2 text-sm text-gray-600 hover:text-[#0e1a30]"
            >
              <Icon icon={faArrowLeft} size="sm" />
              Back to Login
            </Link>
          </CardFooter>
        </Card>
      </div>
    </div>
  );
}

