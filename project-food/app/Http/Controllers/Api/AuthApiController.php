<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthApiController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name'                  => 'required|string|max:255',
            'email'                 => 'required|string|email|max:255|unique:users',
            'password'              => 'required|string|min:6|confirmed',
            'role'                  => 'required|in:user,seller,admin',
        ]);

        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
            'role'     => $request->role,
        ]);

        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'user'  => $this->userResource($user),
            'token' => $token,
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json(['message' => 'Invalid credentials. Please check your email and password.'], 401);
        }

        $user  = Auth::user();
        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'user'  => $this->userResource($user),
            'token' => $token,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out successfully.']);
    }

    public function profile(Request $request)
    {
        return response()->json($this->userResource($request->user()));
    }

    public function updateProfile(Request $request)
    {
        $request->validate([
            'name'         => 'sometimes|string|max:255',
            'phone_number' => 'sometimes|nullable|string|max:20',
            'address'      => 'sometimes|nullable|string|max:500',
        ]);

        $user = $request->user();
        $user->update($request->only(['name', 'phone_number', 'address']));

        return response()->json(['user' => $this->userResource($user)]);
    }

    private function userResource(User $user): array
    {
        return [
            'id'           => $user->id,
            'name'         => $user->name,
            'email'        => $user->email,
            'role'         => $user->role,
            'phone_number' => $user->phone_number,
            'address'      => $user->address,
        ];
    }
}
