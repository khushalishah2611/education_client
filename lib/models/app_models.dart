import 'package:flutter/material.dart';

@immutable
class UniversityData {
  const UniversityData({
    required this.name,
    required this.location,
    required this.shortCode,
    required this.color,
    required this.heroImage,
  });

  final String name;
  final String location;
  final String shortCode;
  final Color color;
  final String heroImage;
}

@immutable
class CourseData {
  const CourseData({
    required this.title,
    required this.duration,
    required this.fee,
    required this.image,
  });

  final String title;
  final String duration;
  final String fee;
  final String image;
}

const universityCatalog = [
  UniversityData(
    name: 'United Arab Emirates University',
    location: 'United Arab Emirates',
    shortCode: 'UAEU',
    color: Color(0xFFE53935),
    heroImage: 'https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=1200&q=80',
  ),
  UniversityData(
    name: 'Al-Ahliyya Amman University',
    location: 'Jordan',
    shortCode: 'AAU',
    color: Color(0xFF486AAE),
    heroImage: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=1200&q=80',
  ),
  UniversityData(
    name: 'Beirut Arab University',
    location: 'Lebanon',
    shortCode: 'BAU',
    color: Color(0xFF7092B9),
    heroImage: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?auto=format&fit=crop&w=1200&q=80',
  ),
  UniversityData(
    name: 'University of Sharjah',
    location: 'Sharjah',
    shortCode: 'UOS',
    color: Color(0xFF3A9D58),
    heroImage: 'https://images.unsplash.com/photo-1564981797816-1043664bf78d?auto=format&fit=crop&w=1200&q=80',
  ),
];

const courseCatalog = [
  CourseData(
    title: 'Bachelor of Computer Science',
    duration: '3 Years',
    fee: '₹60,000 / Year',
    image: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=900&q=80',
  ),
  CourseData(
    title: 'Master of Business Administration (MBA)',
    duration: '2 Years',
    fee: '₹60,000 / Year',
    image: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=900&q=80',
  ),
  CourseData(
    title: 'Bachelor of Information Technology',
    duration: '2 Years',
    fee: '₹60,000 / Year',
    image: 'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&w=900&q=80',
  ),
  CourseData(
    title: 'Bachelor of Engineering (Automobile)',
    duration: '2 Years',
    fee: '₹60,000 / Year',
    image: 'https://images.unsplash.com/photo-1581092580497-e0d23cbdf1dc?auto=format&fit=crop&w=900&q=80',
  ),
  CourseData(
    title: 'Bachelor of Civil Engineering',
    duration: '4 Years',
    fee: '₹72,000 / Year',
    image: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=900&q=80',
  ),
  CourseData(
    title: 'Bachelor of Media Studies',
    duration: '3 Years',
    fee: '₹55,000 / Year',
    image: 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=900&q=80',
  ),
];
