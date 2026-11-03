import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowUpRight } from 'lucide-react';

export function CategoryCard({ title, subtitle, image, icon: Icon, color, to, onClick }) {
  const Tag = to ? Link : 'button';
  return <Tag {...(to ? { to } : { type: 'button', onClick })} className="genre-card" aria-label={title} style={{ '--category-color': color || '#5b233a' }}>
    <img className="genre-card-image" src={image} alt="" width="640" height="640" loading="lazy" decoding="async" onError={event => { event.currentTarget.style.visibility = 'hidden'; }} />
    <span className="genre-card-shade" aria-hidden="true" />
    {Icon && <span className="genre-card-icon" aria-hidden="true"><Icon size={19} /></span>}
    <span className="genre-card-copy"><span className="genre-card-title">{title}</span>{subtitle && <span className="genre-card-subtitle">{subtitle}</span>}</span>
    <span className="genre-card-arrow" aria-hidden="true"><ArrowUpRight size={18} /></span>
  </Tag>;
}
